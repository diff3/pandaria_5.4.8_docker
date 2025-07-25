-- Set all BattlePay shop product prices to 0 (make everything free)

UPDATE `battle_pay_product`
SET `price` = 0, `discount` = 0;