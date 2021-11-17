use fe_common::{diagnostics, files};
use fe_driver::{CompileError, CompiledModule, CompiledContract, compile};
use std::fs;
use std::path::Path;
use std::io::Write;
use fe_common::files::FileStore;
use serde::{Serialize, Deserialize};
use crate::fe::error::{Result, FeError};
use crate::fe::utils::*;
use crate::fe::config::*;


#[derive(Default)]
pub struct Fethers {
    pub config: Fig,
    pub module: Option<CompiledModule>
}


impl Fethers {
    pub fn compile(&mut self) -> Result<&mut Self> {
        if self.config.input_file.is_none() {
            return Err(
                FeError::NoContracts("Please specify a contract to compile".to_string())
            );
        }


        let mut files = FileStore::new();
        let (file_content, file_id) = files.load_file(self.config.input_file.as_ref().unwrap().to_str().unwrap())?;


        let module = compile(&files, file_id, &file_content, false, false);
        let mut module = match module {
            Ok(m) => m,
            Err(e) => {
                diagnostics::print_diagnostics(&e.0, &files);
                return Err(FeError::fe(format!("Unable to compile contract {}", self.config.input_file.as_ref().unwrap().to_str().unwrap())));
            }
        };

        #[cfg(feature = "fe-full")]
         if self.config.flags.bytecode {
            let contracts = module.contracts.clone();
            let bins = compile_yul_contracts(contracts, false)?;
            if self.config.out_dir.is_some() {
                write_module(self.config.out_dir.as_ref().unwrap(), &mut module, true, Some(bins))?;
            }
        }

        if self.config.out_dir.is_some() {
            write_module(self.config.out_dir.as_ref().unwrap(), &mut module, true, None)?;
        }

        self.module = Some(module);
        Ok(self)
    }
}