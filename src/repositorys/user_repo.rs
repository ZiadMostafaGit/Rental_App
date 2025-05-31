use std::fmt::Display;
use std::io::ErrorKind;

use crate::models::User;
use mysql::from_value;
use mysql::params;
use mysql::Conn;
use mysql::Error as MySqlError;
use mysql::{prelude::*, Opts, OptsBuilder, Pool, PooledConn};

struct user_repo {
    pool: Pool,
}

#[derive(Debug)]
pub enum UpdateUserError {
    InvalidRoleChange,
    MySql(mysql::Error),
}

impl From<mysql::Error> for UpdateUserError {
    fn from(err: mysql::Error) -> Self {
        UpdateUserError::MySql(err)
    }
}

impl user_repo {
    pub fn new(database_url: &str) -> Result<Self, MySqlError> {
        let cred = Opts::from_url(database_url)?;
        let pool = Pool::new(cred)?;
        Ok(user_repo { pool })
    }

    fn connect(&self) -> Result<PooledConn, MySqlError> {
        let connection = self.pool.get_conn();
        connection
    }

    fn get_all_users(&self) -> Result<Vec<User>, MySqlError> {
        let mut conn = self.connect()?;
        let query = "SELECT id, first_name, last_name, role, gender, state, city, 
                    street, score, email, password FROM users";

        let result = conn.query_map(
            query,
            |(
                id,
                first_name,
                last_name,
                role,
                gender,
                state,
                city,
                street,
                score,
                email,
                password,
            )| {
                User {
                    id,
                    first_name,
                    last_name,
                    role,
                    gender,
                    state,
                    city,
                    street,
                    score,
                    email,
                    password,
                }
            },
        )?;

        Ok(result)
    }

    fn get_all_customers(&self) -> Result<Vec<User>, MySqlError> {
        let mut conn = self.connect()?;

        let query = "SELECT id, first_name, last_name, role, gender, state, city, 
                    street, score, email, password FROM users WHERE role = customer";

        let result = conn.query_map(
            query,
            |(
                id,
                first_name,
                last_name,
                role,
                gender,
                state,
                city,
                street,
                score,
                email,
                password,
            )| {
                User {
                    id,
                    first_name,
                    last_name,
                    role,
                    gender,
                    state,
                    city,
                    street,
                    score,
                    email,
                    password,
                }
            },
        )?;

        Ok(result)
    }

    fn get_all_lenders(&self) -> Result<Vec<User>, MySqlError> {
        let mut conn = self.connect()?;

        let query = "SELECT id, first_name, last_name, role, gender, state, city, 
                    street, score, email, password FROM users WHERE role = lender";

        let result = conn.query_map(
            query,
            |(
                id,
                first_name,
                last_name,
                role,
                gender,
                state,
                city,
                street,
                score,
                email,
                password,
            )| {
                User {
                    id,
                    first_name,
                    last_name,
                    role,
                    gender,
                    state,
                    city,
                    street,
                    score,
                    email,
                    password,
                }
            },
        )?;

        Ok(result)
    }

    fn get_all_admin(&self) -> Result<Vec<User>, MySqlError> {
        let mut conn = self.connect()?;

        let query = "SELECT id, first_name, last_name, role, gender, state, city, 
                    street, score, email, password FROM users WHERE role = admin";

        let result = conn.query_map(
            query,
            |(
                id,
                first_name,
                last_name,
                role,
                gender,
                state,
                city,
                street,
                score,
                email,
                password,
            )| {
                User {
                    id,
                    first_name,
                    last_name,
                    role,
                    gender,
                    state,
                    city,
                    street,
                    score,
                    email,
                    password,
                }
            },
        )?;

        Ok(result)
    }

    pub fn get_user_by_id(&self, id: i64) -> Result<Option<User>, MySqlError> {
        let mut conn = self.connect()?;

        let query = "SELECT id, first_name, last_name, role, gender, state, city, 
                    street, score, email, password FROM users WHERE id = :id";

        let result = conn.exec_first(query, params! { "id" => id })?;

        Ok(result.map(
            |(
                id,
                first_name,
                last_name,
                role,
                gender,
                state,
                city,
                street,
                score,
                email,
                password,
            )| {
                User {
                    id,
                    first_name,
                    last_name,
                    role,
                    gender,
                    state,
                    city,
                    street,
                    score,
                    email,
                    password,
                }
            },
        ))
    }

    pub fn get_user_by_email_and_password(
        &self,
        email: String,
        password: String,
    ) -> Result<Option<User>, MySqlError> {
        let mut conn = self.connect()?;

        let query = "SELECT id, first_name, last_name, role, gender, state, city, 
                    street, score, email, password FROM users WHERE email= :email AND password=:password";

        let result = conn.exec_first(query, params! { "email" => email,"password"=>password })?;

        Ok(result.map(
            |(
                id,
                first_name,
                last_name,
                role,
                gender,
                state,
                city,
                street,
                score,
                email,
                password,
            )| {
                User {
                    id,
                    first_name,
                    last_name,
                    role,
                    gender,
                    state,
                    city,
                    street,
                    score,
                    email,
                    password,
                }
            },
        ))
    }

    pub fn create_user(&self, user: &User) -> Result<i64, MySqlError> {
        let mut conn = self.connect()?;

        conn.exec_drop(
            "INSERT INTO users (first_name, last_name, role, gender, state, city, 
                              street, score, email, password) 
             VALUES (:first_name, :last_name, :role, :gender, :state, :city, 
                    :street, :score, :email, :password)",
            params! {
                "first_name" => &user.first_name,
                "last_name" => &user.last_name,
                "role" => &user.role,
                "gender" => &user.gender,
                "state" => &user.state,
                "city" => &user.city,
                "street" => &user.street,
                "score" => user.score,
                "email" => &user.email,
                "password" => &user.password,
            },
        )?;

        Ok(conn.last_insert_id() as i64)
    }

    pub fn update_user(&self, user: &User) -> Result<(), UpdateUserError> {
        if (user.role == "admin") {
            return Err(UpdateUserError::InvalidRoleChange);
        }

        let mut conn = self.connect()?;

        conn.exec_drop(
            "UPDATE users SET 
                first_name = :first_name,
                last_name = :last_name,
                role = :role,
                gender = :gender,
                state = :state,
                city = :city,
                street = :street,
                score = :score,
                email = :email,
                password = :password
             WHERE id = :id",
            params! {
                "id" => user.id,
                "first_name" => &user.first_name,
                "last_name" => &user.last_name,
                "role" => &user.role,
                "gender" => &user.gender,
                "state" => &user.state,
                "city" => &user.city,
                "street" => &user.street,
                "score" => user.score,
                "email" => &user.email,
                "password" => &user.password,
            },
        )?;

        Ok(())
    }

    pub fn delete_user(&self, id: i64) -> Result<(), MySqlError> {
        let mut conn = self.connect()?;

        conn.exec_drop("DELETE FROM users WHERE id = :id", params! { "id" => id })?;

        Ok(())
    }
}
