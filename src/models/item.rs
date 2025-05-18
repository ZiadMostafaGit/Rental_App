pub struct item {
    pub id: u64,
    pub owner_id: u64,
    pub title: String,
    pub description: String,
    pub price: u64,
    pub status: Status,
}

pub enum Status {
    Avelable,
    NotAvelable,
}
