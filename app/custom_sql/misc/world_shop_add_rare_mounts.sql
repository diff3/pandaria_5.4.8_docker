-- ##############################################################
-- Pandaria 5.4.8 Shop Mounts (MoP + Pre-MoP Rare Mounts)
-- All mounts added as free products for testing/demo purposes.
-- ##############################################################

-- === Cobalt Primordial Direhorn ===
INSERT INTO `battle_pay_entry` (`id`, `productId`, `groupId`, `idx`, `title`, `description`, `icon`, `displayId`, `banner`, `flags`)
VALUES
  (200, 200, 2, 0, '|cffa335eeCobalt Primordial Direhorn|r', 'Flying mount', 242352, 28950, 0, 0);

INSERT INTO `battle_pay_product` (`id`, `title`, `description`, `icon`, `price`, `discount`, `displayId`, `type`, `choiceType`, `flags`, `flagsInfo`)
VALUES
  (200, 'Shop: Cobalt Primordial Direhorn', 'Flying mount', 242352, 0, 0, 28950, 0, 1, 47, 0);

INSERT INTO `battle_pay_product_items` (`id`, `itemId`, `count`, `productId`)
VALUES
  (200, 24252, 1, 200);

-- === Thundering Ruby Cloud Serpent ===
INSERT INTO `battle_pay_entry` VALUES
  (201, 201, 2, 1, '|cffa335eeThundering Ruby Cloud Serpent|r', 'Flying mount', 244528, 29223, 0, 0);

INSERT INTO `battle_pay_product` VALUES
  (201, 'Shop: Thundering Ruby Cloud Serpent', 'Flying mount', 244528, 0, 0, 29223, 0, 1, 47, 0);

INSERT INTO `battle_pay_product_items` VALUES
  (201, 71259, 1, 201);

-- === Astral Cloud Serpent ===
INSERT INTO `battle_pay_entry` VALUES
  (202, 202, 2, 2, '|cffa335eeAstral Cloud Serpent|r', 'Flying mount', 243540, 29071, 0, 0);

INSERT INTO `battle_pay_product` VALUES
  (202, 'Shop: Astral Cloud Serpent', 'Flying mount', 243540, 0, 0, 29071, 0, 1, 47, 0);

INSERT INTO `battle_pay_product_items` VALUES
  (202, 60336, 1, 202);

-- === Heavenly Onyx Cloud Serpent ===
INSERT INTO `battle_pay_entry` VALUES
  (203, 203, 2, 3, '|cffa335eeHeavenly Onyx Cloud Serpent|r', 'Flying mount', 243541, 29074, 0, 0);

INSERT INTO `battle_pay_product` VALUES
  (203, 'Shop: Heavenly Onyx Cloud Serpent', 'Flying mount', 243541, 0, 0, 29074, 0, 1, 47, 0);

INSERT INTO `battle_pay_product_items` VALUES
  (203, 60424, 1, 203);

-- === Clutch of Ji-Kun ===
INSERT INTO `battle_pay_entry` VALUES
  (204, 204, 2, 4, '|cffa335eeClutch of Ji-Kun|r', 'Flying mount', 237287, 28702, 0, 0);

INSERT INTO `battle_pay_product` VALUES
  (204, 'Shop: Clutch of Ji-Kun', 'Flying mount', 237287, 0, 0, 28702, 0, 1, 47, 0);

INSERT INTO `battle_pay_product_items` VALUES
  (204, 64884, 1, 204);

-- ##############################################################
-- End of Mount Import File
-- ##############################################################
