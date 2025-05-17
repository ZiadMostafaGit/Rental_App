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
}
