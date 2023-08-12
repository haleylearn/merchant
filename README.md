# Analysis With Merchant

| Column               | Description                                           |
|----------------------|-------------------------------------------------------|
| hour_start           | Start hour of the transaction                         |
| merchant             | Merchant Identifier                                   |
| total_trans          | Total number of transactions                          |
| total_success_trans  | Total number of successful transactions                      |
| payment_gateway      | Payment Gateway, who collect money on behalf of the merchant |
| payment_method       | Payment Method Type such as cards, UPI etc.                  |
| sub_type             | The subtype of the payment option chosen by the customer     |
| bank                 | The customer bank account from which the money is sent       |

success rate = Total number transactions success *100 / Total number of transactions

Some merchants are facing the problem that they are experiencing a drop in success rate. So let's analyze how it happened.

1. Help merchants look back at the drop in success rate by the distribution into buckets.
2. Analysis based on date and which combination of dimension (payment_gateway, payment_method and sub_type) has the impact.
3. Analysis based on date, hour and which combination of dimension (payment_gateway, payment_method and sub_type) has the impact.


### 1. Help merchants look back at the drop in success rate by the distribution into buckets.
   My result:
   
<img align="center" alt="analysis_based_on_range_percent" src="https://github.com/haleylearn/merchant/blob/main/analysis_based_on_range_percent.png" />


### 2. Analysis based on date and which combination of dimension (payment_gateway, payment_method and sub_type) has the impact.
   My result:
   
<img align="center" alt="get_analysis_based_on_date_with_dimension" src="https://github.com/haleylearn/merchant/blob/main/table_w_other_date_exclude_null.png" />


### 3. Analysis based on date, hour and which combination of dimension (payment_gateway, payment_method and sub_type) has the impact.
   My result:
   
<img align="center" alt="get_analysis_based_on_hour_date_and_dimension.png" src="https://github.com/haleylearn/merchant/blob/main/get_analysis_based_on_hour_date_and_dimension.png" />
