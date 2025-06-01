pub struct Item {
    pub id: u64,
    pub owner_id: u64,
    pub title: String,
    pub description: String,
    pub price: f64,
    pub status: String,
    pub images: Vec<String>,
}
