use fe_common::{diagnostics, files};
use fe_driver::{CompileError, CompiledModule, CompiledContract, compile};
use std::fs;
use std::path::{Path, PathBuf};
use std::io::Write;
use serde::{Serialize, Deserialize};
use crate::fe::error::{Result, FeError};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FigFlags {
    pub optimize: bool,
    pub bytecode: bool,
    pub overwrite: bool,
}

impl Default for FigFlags {
    fn default() -> Self {
        Self {
            optimize: false,
            bytecode: false,
            overwrite: true
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct Fig {
    pub input_file: Option<PathBuf>,
    pub out_dir: Option<PathBuf>,
    pub flags: FigFlags
}