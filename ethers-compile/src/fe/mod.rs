pub mod config;
pub mod compile;
pub mod utils;
pub mod error;

use fe_driver::{CompiledModule, CompiledContract};

use crate::{AbstractProject, AbstractProjectBuilder, FileName, ContractName, ContractMap};
use std::path::{Path, PathBuf};
use std::cell::RefCell;
use self::compile::Fethers;

use ethers_core::{abi::Abi, types::Bytes};
#[cfg(any(feature = "fe-full", feature = "solc-full", feature = "test"))]
use ethers_solc::artifacts::{CompactContract, CompactContractRef};

pub struct FeCompactContract(CompiledContract);

#[cfg(any(feature = "fe-full", feature = "solc-full", feature = "test"))]
impl From<FeCompactContract> for CompactContract {
    fn from(f: FeCompactContract) -> CompactContract {
        unimplemented!()
    }
}


#[derive(Default)]
pub struct FeProjectBuilder {
    inner_config: config::Fig,
}


pub struct FeProject {
    inner: RefCell<compile::Fethers>,
}


impl AbstractProject for FeProject {
    type CompilationOutput = CompiledModule;
    type Result = error::Result<CompiledModule>;
    type Builder = FeProjectBuilder;
    type Contract = CompiledContract;

    fn builder() -> Self::Builder {
        let fig = config::Fig::default();
        FeProjectBuilder {
            inner_config: fig
        }
    }

    fn compile(&self) -> Self::Result {
        self.inner.borrow_mut().compile()
    }

    fn contracts_flattened(&self) -> Vec<Self::Contract> {
        todo!()
    }

    fn contracts(&self) -> ContractMap<Self::Contract> {
        todo!()
    }
}

impl AbstractProjectBuilder for FeProjectBuilder {
    type Output = FeProject;
    type Result = error::Result<Self::Output>;

    
    fn build(self) -> Self::Result {
        let fethers = Fethers {
            config: self.inner_config,
            module: None,
        };
        Ok(FeProject {
            inner: RefCell::new(fethers)
        })
    }
}

impl FeProjectBuilder {
    pub fn input(mut self, input: impl Into<PathBuf>) -> Self {
        let mut config = self.inner_config;
        config.input_file = Some(input.into());
        self.inner_config = config;
        self
    }

    pub fn out(mut self, output: impl Into<PathBuf>) -> Self {
        let mut config = self.inner_config;
        config.out_dir = Some(output.into());
        self.inner_config = config;
        self
    }

    pub fn optimize(mut self, optimize: bool) -> Self {
        let mut config = self.inner_config;
        config.flags.optimize = optimize;
        self.inner_config = config;
        self
    }

    pub fn overwrite(mut self, overwrite: bool) -> Self {
        let mut config = self.inner_config;
        config.flags.overwrite = overwrite;
        self.inner_config = config;
        self
    }

    pub fn bytecode(mut self, bytecode: bool) -> Self {
        let mut config = self.inner_config;
        config.flags.bytecode = bytecode;
        self.inner_config = config;
        self
    }


}
