use std::fs;
use rayon::iter::{ParallelBridge, ParallelIterator};
use rand::{Rng, thread_rng};
use rand::distributions::Alphanumeric;
use std::ffi::OsStr;

fn main() {
    let paths = fs::read_dir("./").unwrap();

    paths.par_bridge().for_each(|f| {
        let mut rng = thread_rng();

        let mut name: String = (0..20).map(|_| rng.sample(Alphanumeric) as char).collect();

        let f_path = f.expect("file not found").path();
        let ext =f_path.extension().unwrap_or(OsStr::new("")).to_str().expect("string bugada");

        if ext != "" {
            name.push_str(format!(".{ext}").as_str());
        }
        fs::rename(f_path, name).expect("oopsie doopsie");
    });
}
