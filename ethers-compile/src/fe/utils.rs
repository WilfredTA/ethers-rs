use std::collections::HashMap;
use fe_common::{diagnostics, files};
use std::fs;
use std::path::{Path, PathBuf};
use std::io::Write;
use std::str::FromStr;
use crate::fe::error::{Result, FeError};
use fe_driver::{CompiledContract, CompiledModule};
use serde::{Serialize, Deserialize};

#[cfg(feature = "fe-full")]
use ethers_solc::{CompilerInput, artifacts::{Source, Settings}};
#[cfg(feature = "fe-full")]
use ethers_solc::artifacts::Sources;


pub fn write_module(
    out_dir: impl AsRef<Path>,
    module: &mut CompiledModule,
    _overwrite: bool,
    bins: Option<HashMap<String, String>>,
) -> Result<()> {
    let out_dir = out_dir.as_ref();
    if out_dir.is_file() {
        return Err(FeError::fe(
            format!(
                "A file exists at path `{}`, the location of the output directory. Refusing to overwrite.",
                out_dir.display()
            )
        ));
    }

    fs::create_dir_all(out_dir).map_err(|e| FeError::fe(format!("{}", e)))?;

    write_output(&out_dir.join("module.ast"), &module.src_ast)?;

    for (name, contract) in module.contracts.drain() {
        let contract_out_dir = out_dir.join(&name);

        fs::create_dir_all(&contract_out_dir)?;
        let file_name = format!("{}_abi.json", &name);
        write_output(&contract_out_dir.join(file_name), &contract.json_abi)?;
        let file_name = format!("{}_ir.yul", &name);
        write_output(&contract_out_dir.join(file_name), &contract.yul)?;


    }

    #[cfg(feature = "fe-full")]
    if bins.is_some() {
        for (name, bytecode) in bins.unwrap().drain() {
            let contract_out_dir = out_dir.join(&name);
            let file_name = format!("{}.bin", &name);
            write_output(&contract_out_dir.join(file_name), &bytecode)?;
        }

    }

    Ok(())
}

pub fn write_output(path: &Path, write_contents: &str) -> Result<()> {
    let mut file = fs::OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open(path)?;
    file.write_all(write_contents.as_bytes())?;
    Ok(())
}

#[cfg(feature = "fe-full")]
pub fn compile_yul_contracts(contracts: HashMap<String, CompiledContract>, optimize: bool) -> Result<HashMap<String, String>> {
    let mut compiled = HashMap::new();
    for (name, contract) in contracts {
        let bincode: String = compile_single_yul_contract(contract, optimize)?;
        compiled.insert(name, bincode);
    }

    Ok(compiled)
}
//
// #[derive(Debug, Clone, Serialize, Deserialize)]
// struct ContentSource {
//     content: String
// }
// #[derive(Debug, Clone, Serialize, Deserialize)]
// struct OptimizerSettings {
//     enabled: bool
// }
// #[derive(Debug, Clone, Serialize, Deserialize)]
// struct Settings {
//     optimizer: OptimizerSettings,
//     #[serde(rename = "camelCase")]
//     output_selection: ,
// }
// #[derive(Debug, Clone, Serialize, Deserialize)]
// pub struct SolcYulJsonFile {
//     language: String,
//     sources: HashMap<String, ContentSource>,
//     settings: Settings
// }

#[cfg(feature = "fe-full")]
pub fn compile_single_yul_contract(contract: CompiledContract, _optimize: bool) -> Result<String> {

    let mut sources = Sources::default();
    let yul_src = Source {
        content: contract.yul.clone()
    };
    let yul_src_path = Path::new("input.yul").to_path_buf();
    sources.insert(yul_src_path, yul_src);
    let mut solc_input = CompilerInput::with_sources(sources);
    solc_input.language = "Yul".to_string();
    solc_input.settings.optimizer.enabled = Some(false);


    let solc_output = ethers_solc::Solc::default().compile(&solc_input)?;
    println!("SOLC OUTPUT: {:?}", solc_output);
    // let solc_output: serde_json::Value = serde_json::from_slice(&solc_output)
    //      .map_err(|_| FeError::fe("JSON serialization error"))?;
    // println!("SOLC OUTPUT: {:?}", solc_output);
    Ok(serde_json::json!(solc_output).to_string())

}