use dotenv::dotenv;
use std::env;

pub struct Env {
    pub db_url: String,
    pub jwt_token: String,
    pub jwt_time: String,
}

impl Env {
    pub fn load() -> Self {
        dotenv().ok();

        Env {
            db_url: env::var("DATABASE_URL").expect("unable to load the DATABASE_URL"),
            jwt_token: env::var("JWT_SECRET").expect("unable to load the jwt secret "),
            jwt_time: env::var("JWT_EXPIRATION_SECONDS")
                .expect("unable to load JWT_EXPIRATION_SECONDS"),
        }
    }
}
