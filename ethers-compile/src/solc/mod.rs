
use crate::{AbstractProject, AbstractProjectBuilder, FileName, ContractName, ContractMap};

#[cfg(any(feature = "solc-full", feature = "solc-async"))]
use ethers_solc::{ProjectPathsConfig, ProjectBuilder, Project, ProjectCompileOutput, ArtifactOutput,
                  MinimalCombinedArtifacts, artifacts::{Contract, CompilerOutput, CompactContract},
                  error::Result as SolcResult,
};
use std::collections::{HashMap, BTreeMap};
use std::path::{Path, PathBuf};

#[cfg(any(feature = "solc-full", feature = "solc-async"))]
#[derive(Default)]
pub struct SolcProjectBuilder {
    inner_project: Option<Project>,
    path_config: Option<ProjectPathsConfig>,
    ephemeral: bool,


}
#[cfg(any(feature = "solc-full", feature = "solc-async"))]

pub struct SolcProject {
    inner: Project
}
#[cfg(any(feature = "solc-full", feature = "solc-async"))]

impl AbstractProject for SolcProject {
    type CompilationOutput = ProjectCompileOutput<MinimalCombinedArtifacts>;
    type Builder = SolcProjectBuilder;
    type Contract = Contract;
    type Result =  SolcResult<Self::CompilationOutput>;

    fn builder() -> Self::Builder {
        SolcProjectBuilder::default()
    }

    fn compile(&self) -> Self::Result {
        self.inner.compile()
    }

    fn contracts_flattened(&self) -> Vec<Self::Contract> {
        todo!()
    }

    fn contracts(&self) -> ContractMap<Self::Contract> {
        todo!()
    }
}
#[cfg(any(feature = "solc-full", feature = "solc-async"))]

impl SolcProjectBuilder {
    pub fn new(root: &str, sources: &str, tests: Option<&str>, libraries: Option<&str>, ephemeral: bool) -> Self {
        let project_builder = Project::builder();
        let mut path_config_builder = ProjectPathsConfig::builder()
            .root(PathBuf::from(root.to_string()))
            .sources(PathBuf::from(sources.to_string()));

        if tests.is_some() {
            path_config_builder = path_config_builder.tests(PathBuf::from(tests.unwrap().to_string()));
        }

        if libraries.is_some() {
            path_config_builder = path_config_builder.tests(PathBuf::from(libraries.unwrap().to_string()));
        }

        let path_config = path_config_builder.build().unwrap();


        let mut project = project_builder.paths(path_config.clone());

        if ephemeral {
            project = project.ephemeral();
        }

        let project = project.build().unwrap();
        SolcProjectBuilder {
            inner_project: Some(project),
            path_config: Some(path_config),
            ephemeral,

        }
    }

    pub fn sources(self, sources: impl Into<PathBuf>) -> Self {
        if let Some(path_config) = self.path_config {
            let mut path_config = path_config;
            path_config.sources = sources.into();
            let new_builder = SolcProjectBuilder {
                path_config: Some(path_config),
                inner_project: self.inner_project,
                ephemeral: self.ephemeral
            };
            new_builder
        } else {
            let path_config = ProjectPathsConfig::builder()
                .sources(sources)
                .build()
                .unwrap();
            let new_builder = SolcProjectBuilder {
                path_config: Some(path_config),
                inner_project: self.inner_project,
                ephemeral: self.ephemeral
            };
            new_builder
        }
    }

    pub fn lib(self, lib: impl Into<PathBuf>) -> Self {
        if let Some(path_config) = self.path_config {
            let mut path_config = path_config;
            path_config.libraries.push(lib.into());
            let new_builder = SolcProjectBuilder {
                path_config: Some(path_config),
                inner_project: self.inner_project,
                ephemeral: self.ephemeral
            };
            new_builder
        } else {
            let path_config = ProjectPathsConfig::builder()
                .lib(lib)
                .build()
                .unwrap();
            let new_builder = SolcProjectBuilder {
                path_config: Some(path_config),
                inner_project: self.inner_project,
                ephemeral: self.ephemeral
            };
            new_builder
        }
    }

    pub fn root(self, root: impl Into<PathBuf>) -> Self {
        if let Some(path_config) = self.path_config {
            let mut path_config = path_config;
            path_config.root = root.into();
            let new_builder = SolcProjectBuilder {
                path_config: Some(path_config),
                inner_project: self.inner_project,
                ephemeral: self.ephemeral
            };
            new_builder
        } else {
            let path_config = ProjectPathsConfig::builder()
                .root(root)
                .build()
                .unwrap();
            let new_builder = SolcProjectBuilder {
                path_config: Some(path_config),
                inner_project: self.inner_project,
                ephemeral: self.ephemeral
            };
            new_builder
        }
    }
}
#[cfg(any(feature = "solc-full", feature = "solc-async"))]

impl AbstractProjectBuilder for SolcProjectBuilder {
    type Result = SolcResult<SolcProject>;
    type Output = SolcProject;


    fn build(self) -> Self::Result {
        if let Some(proj) = self.inner_project {
            Ok(SolcProject{inner: proj})
        } else {
            let paths_config = self.path_config.unwrap();
            let ephemeral = self.ephemeral;

            let mut project = Project::builder()
                .paths(paths_config);

            if ephemeral {
                project = project.ephemeral();
            }

            let project = project.build()?;
            Ok(SolcProject {
                inner: project
            })
        }

    }
}
