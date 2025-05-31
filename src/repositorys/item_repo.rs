use std::fmt::Display;
use std::io::ErrorKind;
use std::ops;

use crate::models::item::Item;
use mysql::from_value;
use mysql::params;
use mysql::Conn;
use mysql::Error as MySqlError;
use mysql::Statement;
use mysql::{prelude::*, Opts, OptsBuilder, Pool, PooledConn};

pub struct item_repo {
    pool: Pool,
}

impl item_repo {
    pub fn new(DATABASE_URL: &str) -> Result<Self, MySqlError> {
        let parms = Opts::from_url(DATABASE_URL)?;
        let pool = Pool::new(parms)?;

        Ok(Self { pool })
    }

    pub fn connect(&self) -> Result<PooledConn, MySqlError> {
        let connection = self.pool.get_conn()?;
        Ok(connection)
    }

    pub fn get_items(&self) -> Result<Vec<Item>, MySqlError> {
        let mut conn = self.connect()?;

        let mut items: Vec<Item> = conn.query_map(
            "SELECT id, owner_id, title, description, price, status FROM items ORDER BY id",
            |(id, owner_id, title, description, price, status)| Item {
                id,
                owner_id,
                title,
                description,
                price,
                status,
                images: Vec::new(),
            },
        )?;

        let images: Vec<(u64, String)> =
            conn.query("SELECT item_id, image_url FROM item_images ORDER BY item_id")?;

        let mut image_index = 0;
        let mut item_index = 0;

        while item_index < items.len() && image_index < images.len() {
            let item_id = items[item_index].id;

            while image_index < images.len() && images[image_index].0 == item_id {
                let image_url = &images[image_index].1;
                items[item_index].images.push(image_url.clone());
                image_index += 1;
            }

            item_index += 1;
        }

        Ok(items)
    }

    pub fn get_item_by_id(&self, id: i32) -> Result<Option<Item>, MySqlError> {
        let mut conn = self.connect()?;

        let item_row = conn.exec_first(
            "SELECT id, owner_id, title, description, price, status FROM items WHERE id = ?",
            (id,),
        )?;

        if let Some((id, owner_id, title, description, price, status)) = item_row {
            let images: Vec<String> = conn.exec_map(
                "SELECT image_url FROM item_images WHERE item_id = ?",
                (id,),
                |image_url| image_url,
            )?;

            Ok(Some(Item {
                id,
                owner_id,
                title,
                description,
                price,
                status,
                images,
            }))
        } else {
            Ok(None)
        }
    }

    pub fn get_items_with_price_greater_than(&self, price: f64) -> Result<Vec<Item>, MySqlError> {
        let mut conn = self.connect()?;

        let query = r#"
        SELECT id, owner_id, title, description, price, status, 
        FROM items 
        WHERE price > :price
    "#;

        let result = conn.exec_map(
            query,
            params! { "price" => price },
            |(id, owner_id, title, description, price, status)| Item {
                id,
                owner_id,
                title,
                description,
                price,
                status,
                images: Vec::new(),
            },
        )?;

        Ok(result)
    }
}
