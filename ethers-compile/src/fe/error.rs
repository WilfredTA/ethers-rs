use thiserror::Error;
use fe_driver::CompileError;
use fe_common::diagnostics;
pub type Result<T> = std::result::Result<T, FeError>;

#[cfg(feature = "fe-full")]
use ethers_solc::error::SolcError;
/// Various error types
#[derive(Debug, Error)]
pub enum FeError {
    #[error("Encounter error with Fe {0}")]
    FeError(String),
    /// Deserialization error
    #[error(transparent)]
    SerdeJson(#[from] serde_json::Error),
    /// Deserialization error
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error("no contracts found at")]
    NoContracts(String),
    #[cfg(feature = "fe-full")]
    #[error(transparent)]
    FeSolc(#[from] SolcError)
}

impl FeError {
    pub(crate) fn fe(msg: impl Into<String>) -> Self {
        FeError::FeError(msg.into())
    }
}