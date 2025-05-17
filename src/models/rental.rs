use chrono::NaiveDate;

struct Rental {
    id: u64,
    item_id: u64,
    user_id: u64,
    start: NaiveDate,
    end: NaiveDate,
    current_states: String,
    estimated_time: u8,
    delivary_address: String,
}
