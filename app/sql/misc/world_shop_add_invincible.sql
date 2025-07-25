-- Add Invincible's Reins (Icecrown Citadel mount) to BattlePay shop (Free)

-- Step 1: Add to shop entry (visible in Mounts group)
INSERT INTO `battle_pay_entry`
(`id`, `productId`, `groupId`, `idx`, `title`, `description`, `icon`, `displayId`, `banner`, `flags`)
VALUES
(200, 200, 2, 0,
'|cffa335eeInvincible''s Reins|r',
'Flying mount from Icecrown Citadel (Lich King)',
'294032',    -- icon (Ironbound proto-drake style icon, change if needed)
28953,       -- displayId (Invincible’s Reins visual model)
2,           -- banner type (matches mounts)
0);          -- flags (default)

-- Step 2: Define product (price set to 0 for free)
INSERT INTO `battle_pay_product`
(`id`, `title`, `description`, `icon`, `price`, `discount`, `displayId`, `type`, `choiceType`, `flags`, `flagsInfo`)
VALUES
(200,
'Shop: Invincible''s Reins',
'Flying mount from Icecrown Citadel (Lich King)',
'294032',    -- icon
0,           -- price (0 = free)
0,           -- discount
28953,       -- displayId (matches above)
0,           -- type (0 = mount/pet)
1,           -- choiceType (1 = single purchase)
47,          -- flags (same as other mounts)
0);          -- flagsInfo

-- Step 3: Link product to the actual mount item (Invincible’s Reins itemId: 50818)
INSERT INTO `battle_pay_product_items`
(`id`, `itemId`, `count`, `productId`)
VALUES
(200, 50818, 1, 200);