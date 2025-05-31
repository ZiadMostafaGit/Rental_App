mod auth;
mod config;
mod models;
mod repositorys;
mod routes;
mod services;
use dotenv::dotenv;
use std::env;

fn main() {
    let config = config::configs::Env::load();
    println!("everything is just working ");
    println!("db_url is {}", config.db_url);
    println!("jwt_token is {}", config.jwt_token);
    let i_repo = repositorys::item_repo::item_repo::new(&config.db_url).unwrap();
    let i: models::item::Item = i_repo.get_item_by_id(1).unwrap().unwrap();

    println!("item id is {}", i.id);
    println!("item title is {}", i.title);
    println!("item description is {}", i.description);
    println!("item price is {}", i.price);
    println!("item status is {}", i.status);
    println!("item owner_id is {}", i.owner_id);
    println!("item images are {:?}", i.images);
}
