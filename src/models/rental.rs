use chrono::NaiveDate;

pub struct Rental {
    pub id: u64,
    pub item_id: u64,
    pub user_id: u64,
    pub start: NaiveDate,
    pub end: NaiveDate,
    pub current_states: CurrentStatus,
    pub estimated_time: u8,
    pub delivary_address: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CurrentStatus {
    Pending,
    Shipped,
    Delivered,
    Cancelled,
}
