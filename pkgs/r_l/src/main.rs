use jwalk::WalkDir;
use rand::seq::SliceRandom;
use std::env;
use std::path::Path;
use std::time::Instant;
use tokio::task;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let start = Instant::now();
    let init = Path::new("/run/media/lucas/9282048d-b2a4-47b7-b0f4-14c877d494d0/OneDrive/uau/");
    let fin = Path::new("/run/media/lucas/9282048d-b2a4-47b7-b0f4-14c877d494d0/OneDrive/P_L/");
    let args: Vec<String> = env::args().collect();
    let no_of_files: usize = args[1].trim().parse().unwrap();
    println!("{no_of_files}");
    let paths = WalkDir::new(init)
        .into_iter()
        .filter_map(|e| e.ok())
        .map(|x| x.path().to_str().unwrap().to_string())
        .collect::<Vec<String>>();
    // let paths = fs::read_dir(init)
    //     .unwrap()
    //     .par_bridge()
    //     .into_par_iter()
    //     .map(|entry| {
    //         let entry = entry.unwrap();
    //         let entry_path = entry.path();
    //         let path_as_str = entry_path.to_str().unwrap();
    //         String::from(path_as_str)
    //     })
    //     .collect::<Vec<String>>();
    let mut rng = &mut rand::thread_rng();

    let paths: Vec<String> = paths
        .choose_multiple(&mut rng, no_of_files)
        .cloned()
        .collect();

    let start_transf = Instant::now();
    let mut i = 1;
    let mut threads = Vec::new();
    for file_name in paths {
        let task = task::spawn(async move {
            let file_name_as_buf = Path::new(&file_name);
            let interm = file_name_as_buf.file_name().unwrap().to_str().unwrap();
            let end = format!("{}/{:03} - {}", fin.to_str().unwrap(), i, interm);
            let end = Path::new(&end);
            match tokio::fs::copy(file_name_as_buf, end).await {
                Ok(_) => {
                    println!(
                        "copiando de {} para {}",
                        file_name_as_buf.to_str().unwrap(),
                        end.to_str().unwrap()
                    );
                }
                Err(_) => panic!("problema no arquivo {}", file_name_as_buf.display()),
            }
        });
        threads.push(task);
        i += 1;
    }
    for handle in threads {
        handle.await?
    }
    let duration_transf = start_transf.elapsed();
    let duration = start.elapsed();
    println!(
        "tempo total = {:.2} segundos
tempo das transferências = {:.2} segundos",
        (duration.as_millis() as f64) / 1000.0,
        (duration_transf.as_millis() as f64) / 1000.0
    );
    Ok(())
}
