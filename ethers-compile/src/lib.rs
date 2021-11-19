use std::collections::{HashMap, BTreeMap};
use std::path::{Path, PathBuf};

mod fe;
mod solc;


#[cfg(any(feature = "fe-full", feature = "fe-ir", feature = "test"))]
pub use fe::*;

#[cfg(any(feature = "solc-full", feature = "solc-async", feature = "test"))]
pub use solc::{SolcProject, SolcProjectBuilder};

use ethers_core::{abi::Abi};

pub type FileName = String;
pub type ContractName = String;
pub type ContractMap<C> = BTreeMap<FileName, BTreeMap<ContractName, C>>;



pub trait AbstractProjectBuilder {
    type Output;
    type Result;
    fn build(self) -> Self::Result;
}

pub trait AbstractProject {
    type Result;
    type CompilationOutput;
    type Builder: AbstractProjectBuilder<Output = Self>;
    type Contract;
    fn builder() -> Self::Builder;
    fn compile(&self) -> Self::Result;
    fn contracts_flattened(&self) -> Vec<Self::Contract>;
    fn contracts(&self) -> ContractMap<Self::Contract>;
}


#[cfg(test)]
#[cfg(feature = "test")]
mod tests {
    use tempdir::TempDir;
    use std::path::PathBuf;
    use std::str::FromStr;
    use super::fe::*;
    use super::fe::utils::compile_single_yul_contract;
    use fe_driver::CompiledContract;

    use super::solc::{SolcProjectBuilder, SolcProject};
    use super::{ AbstractProjectBuilder, AbstractProject};

    #[test]
    fn solc_project_build_works() {
        let root = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("test-data/solc/dapp-sample");
        let project = SolcProjectBuilder::default()
            .root(root.clone())
            .sources(root.join("src"))
            .lib(root.join("lib"))
            .build()
            .unwrap();
        let compile_result = project.compile().unwrap();
        println!("{:#?}", compile_result);
    }
    #[test]
    fn compile_fe_to_yul_ir() {
        let tmp = TempDir::new("root").unwrap();
        let out_dir = tmp.path().join("artifacts");
        let target_file = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("test-data/fe/guest_book.fe");
        let fe_project = FeProject::builder()
            .input(&target_file)
            .out(&out_dir)
            .overwrite(true)
            .build()
            .unwrap();
        let compile_result = fe_project.compile().unwrap();
        println!("{:#?}", compile_result.contracts);
        // let mut fe_config = config::Fig::default();
        // fe_config.out_dir = Some(out_dir.clone());
        // fe_config.input_file = Some(target_file.clone());

        // let mut fethers = compile::Fethers {
        //     config: fe_config,
        //     module: None
        // };
        // let module = fethers.compile().unwrap();

        assert!(out_dir.join("module.ast").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_abi.json").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_ir.yul").is_file());
        assert_eq!(out_dir.join("GuestBook/GuestBook.bin").is_file(), false);
    }

    #[test]
    fn read_and_compile_yul() {
        let yul_file = include_str!("../test-data/fe/artifacts/GuestBook/GuestBook_ir.yul");
        let abi_file = include_str!("../test-data/fe/artifacts/GuestBook/GuestBook_abi.json");
        
        let contract = CompiledContract {
            json_abi: abi_file.to_string(),
            yul: yul_file.to_string(),
        };
        println!("{:#?}", yul_file);

        let compiled = compile_single_yul_contract(contract, false);
        
    }
    #[test]
    fn compile_fe_to_evm() {
        let tmp = TempDir::new("root").unwrap();
        //let out_dir = tmp.path().join("artifacts");
        let out_dir = PathBuf::from("test-data/fe/artifacts");
        let target_file = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("test-data/fe/guest_book.fe");
        let fe_project = FeProject::builder()
        .input(&target_file)
        .out(&out_dir)
        .overwrite(true)
        .bytecode(true)
        .build()
        .unwrap();
        let compile_result = fe_project.compile().unwrap();
        println!("{:#?}", compile_result.contracts);
        // let mut fe_config = config::Fig::default();
        // fe_config.flags.bytecode = true;
        // fe_config.out_dir = Some(out_dir.clone());
        // fe_config.input_file = Some(target_file.clone());

        // let mut fethers = compile::Fethers {
        //     config: fe_config,
        //     module: None
        // };
        // let module = fethers.compile().unwrap();


        assert!(out_dir.join("module.ast").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_abi.json").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_ir.yul").is_file());
        assert!(out_dir.join("GuestBook/GuestBook.bin").is_file());
    }
}
