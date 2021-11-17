pub mod fe;

#[cfg(test)]
mod tests {
    use tempdir::TempDir;
    use std::path::PathBuf;
    use super::fe::*;
    #[test]
    fn compile_fe_to_yul_ir() {
        let tmp = TempDir::new("root").unwrap();
        let out_dir = tmp.path().join("artifacts");
        let target_file = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("test-data/guest_book.fe");
        let mut fe_config = config::Fig::default();
        fe_config.out_dir = Some(out_dir.clone());
        fe_config.input_file = Some(target_file.clone());

        let mut fethers = compile::Fethers {
            config: fe_config,
            module: None
        };
        fethers.compile().unwrap();

        assert!(out_dir.join("module.ast").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_abi.json").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_ir.yul").is_file());
        assert_eq!(out_dir.join("GuestBook/GuestBook.bin").is_file(), false);
    }

    #[test]
    #[cfg(feature = "fe-full")]
    fn compile_fe_to_evm() {
        let tmp = TempDir::new("root").unwrap();
        let out_dir = tmp.path().join("artifacts");
        let target_file = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("test-data/guest_book.fe");
        let mut fe_config = config::Fig::default();
        fe_config.flags.bytecode = true;
        fe_config.out_dir = Some(out_dir.clone());
        fe_config.input_file = Some(target_file.clone());

        let mut fethers = compile::Fethers {
            config: fe_config,
            module: None
        };
        fethers.compile().unwrap();


        assert!(out_dir.join("module.ast").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_abi.json").is_file());
        assert!(out_dir.join("GuestBook/GuestBook_ir.yul").is_file());
        assert!(out_dir.join("GuestBook/GuestBook.bin").is_file());
    }
}
