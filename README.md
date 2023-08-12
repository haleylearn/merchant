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
