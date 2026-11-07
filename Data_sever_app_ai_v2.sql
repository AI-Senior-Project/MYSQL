-- Schema (MySQL / MariaDB)  -- v2
-- v2: เพิ่ม updated_at / deleted_at (soft delete) ในตารางที่แก้ไข/ลบได้ เพื่อใช้ซิงค์ offline-online
-- กติกา: primary key ทั่วไป = BIGINT AUTO_INCREMENT PRIMARY KEY
--        FK ใช้ type เดียวกับ PK ที่อ้างถึงเสมอ
--        branch_id และ employee_id เป็นรหัสแยก (VARCHAR) ไม่ใช่ PK
--
-- ตารางที่เปลี่ยน PK เป็นรหัสประสม (สร้างจากแอป เพื่อให้ทำงาน offline ได้ไม่ชนกัน):
--   History_Store_Product, History_Store_Equipment, Bill, Basket,
--   History_Business, History_Edit_Product, History_Edit_Equipment, History_Branch, History_Employee
-- รูปแบบรหัส:  YYYYMMDDHHMMSS-รหัสสาขา-รหัสพนักงาน-สุ่ม4ตัว
-- ตัวอย่าง:    20261107094900-B001-E005-X7K2
--   * รหัสสาขา  = Branch.branch_id
--   * รหัสพนักงาน = Employee.employee_id  (ถ้าเจ้าของร้านเป็นคนทำรายการ ให้ใช้ 'OWNER' หรือ 'U'+id_user)
--   * ควรตั้ง branch_id / employee_id ให้สั้น (ไม่เกิน ~20 ตัวอักษร) และไม่มีเครื่องหมาย '-'
--   * คอลัมน์รหัสใช้ ascii + ascii_bin เพื่อให้ index เล็กและเทียบแบบ case-sensitive

CREATE TABLE `User` (
  id_user      BIGINT AUTO_INCREMENT PRIMARY KEY,
  firstname    VARCHAR(100) NOT NULL,
  lastname     VARCHAR(100) NOT NULL,
  image        VARCHAR(500),
  age          TINYINT UNSIGNED,
  login_id     VARCHAR(100) NOT NULL UNIQUE,
  password     VARCHAR(255) NOT NULL,            -- เก็บเป็น hash
  `date`       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL
);

CREATE TABLE Business (
  id_business    BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_user        BIGINT NOT NULL,
  name_business  VARCHAR(200) NOT NULL,
  logo           VARCHAR(500),
  `date`         DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_user) REFERENCES `User`(id_user)
);

-- PK เป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Business (
  id_history_business VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_business         BIGINT NOT NULL,
  details             TEXT,
  `date`              DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_business) REFERENCES Business(id_business)
);

CREATE TABLE Product (
  id_product   BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_business  BIGINT NOT NULL,
  sku          VARCHAR(100) NOT NULL,
  barcode      VARCHAR(100),
  name         VARCHAR(200) NOT NULL,
  `type`       VARCHAR(100),
  price        DECIMAL(12,2) NOT NULL DEFAULT 0,
  details      TEXT,
  image        VARCHAR(500),
  type_sell    VARCHAR(50),
  `date`       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_business) REFERENCES Business(id_business)
);

-- PK เป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Edit_Product (
  id_edit_product VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_business     BIGINT NOT NULL,
  id_product      BIGINT NOT NULL,
  details         TEXT,
  `date`          DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_business) REFERENCES Business(id_business),
  FOREIGN KEY (id_product)  REFERENCES Product(id_product)
);

CREATE TABLE Equipment (
  id_equipment BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_business  BIGINT NOT NULL,
  sku          VARCHAR(100) NOT NULL,
  name         VARCHAR(200) NOT NULL,
  `type`       VARCHAR(100),
  details      TEXT,
  image        VARCHAR(500),
  `date`       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_business) REFERENCES Business(id_business)
);

-- PK เป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Edit_Equipment (
  id_edit_equipment VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_business       BIGINT NOT NULL,
  id_equipment      BIGINT NOT NULL,
  details           TEXT,
  `date`            DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_business)  REFERENCES Business(id_business),
  FOREIGN KEY (id_equipment) REFERENCES Equipment(id_equipment)
);

CREATE TABLE Branch (
  id_branch    BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_business  BIGINT NOT NULL,
  branch_id    VARCHAR(100) NOT NULL,
  name         VARCHAR(200) NOT NULL,
  location     VARCHAR(500),
  `date`       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_business) REFERENCES Business(id_business)
);

-- PK เป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Branch (
  id_history_branch VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_branch         BIGINT NOT NULL,
  details           TEXT,
  `date`            DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_branch) REFERENCES Branch(id_branch)
);

CREATE TABLE Employee (
  id_employee  BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_branch    BIGINT NOT NULL,
  employee_id  VARCHAR(100) NOT NULL,
  firstname    VARCHAR(100) NOT NULL,
  lastname     VARCHAR(100) NOT NULL,
  `position`   VARCHAR(100),
  salary       DECIMAL(12,2),
  image        VARCHAR(500),
  login_id     VARCHAR(100) NOT NULL UNIQUE,
  password     VARCHAR(255) NOT NULL,            -- เก็บเป็น hash
  `date`       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_branch) REFERENCES Branch(id_branch)
);

-- PK เป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Employee (
  id_history_employee VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_branch           BIGINT NOT NULL,
  id_employee         BIGINT NOT NULL,
  details             TEXT,
  `date`              DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_branch)   REFERENCES Branch(id_branch),
  FOREIGN KEY (id_employee) REFERENCES Employee(id_employee)
);

CREATE TABLE Store_Product (
  id_store_product BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_branch        BIGINT NOT NULL,
  id_product       BIGINT NOT NULL,
  quantity         DECIMAL(12,2) NOT NULL DEFAULT 0,
  mfg_date         DATE,
  exp_date         DATE,
  location         VARCHAR(200),
  `date`           DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_branch)  REFERENCES Branch(id_branch),
  FOREIGN KEY (id_product) REFERENCES Product(id_product)
);

-- PK เปลี่ยนเป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Store_Product (
  id_history_store_product VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_branch                BIGINT NOT NULL,
  id_product               BIGINT NOT NULL,
  `type`                   VARCHAR(50),           -- เช่น in / out / adjust
  `before`                 DECIMAL(12,2),
  `after`                  DECIMAL(12,2),
  edit_name                VARCHAR(100) NOT NULL,
  details                  TEXT,
  `date`                   DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_branch)  REFERENCES Branch(id_branch),
  FOREIGN KEY (id_product) REFERENCES Product(id_product)
);

CREATE TABLE Store_Equipment (
  id_store_equipment BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_branch          BIGINT NOT NULL,
  id_equipment       BIGINT NOT NULL,
  quantity           DECIMAL(12,2) NOT NULL DEFAULT 0,
  mfg_date           DATE,
  exp_date           DATE,
  location           VARCHAR(200),
  `date`             DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_branch)    REFERENCES Branch(id_branch),
  FOREIGN KEY (id_equipment) REFERENCES Equipment(id_equipment)
);

-- PK เปลี่ยนเป็นรหัสประสม: วันเวลา-รหัสสาขา-รหัสพนักงาน-สุ่ม
CREATE TABLE History_Store_Equipment (
  id_history_store_equipment VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_branch                  BIGINT NOT NULL,
  id_equipment               BIGINT NOT NULL,
  `type`                     VARCHAR(50),
  `before`                   DECIMAL(12,2),
  `after`                    DECIMAL(12,2),
  edit_name                  VARCHAR(100) NOT NULL,
  details                    TEXT,
  `date`                     DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_branch)    REFERENCES Branch(id_branch),
  FOREIGN KEY (id_equipment) REFERENCES Equipment(id_equipment)
);

CREATE TABLE Promotion (
  id_promotions  BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_business    BIGINT NOT NULL,
  name           VARCHAR(200) NOT NULL,
  discount_type  VARCHAR(20),                     -- percent / amount
  discount_value DECIMAL(12,2),
  start_date     DATETIME,
  end_date       DATETIME,
  status         VARCHAR(20),
  `date`         DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME NULL,
  FOREIGN KEY (id_business) REFERENCES Business(id_business)
);

-- PK id_bill เป็นรหัสบิลประสมเลย (แทน bill_id เดิมที่เป็นคอลัมน์แยก จึงตัด bill_id ออก)
CREATE TABLE Bill (
  id_bill        VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_branch      BIGINT NOT NULL,
  id_employee    BIGINT,
  id_user        BIGINT,
  total_price    DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount       DECIMAL(12,2) DEFAULT 0,
  id_promotions  BIGINT,
  type_pay       VARCHAR(30),
  `date`         DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_branch)     REFERENCES Branch(id_branch),
  FOREIGN KEY (id_employee)   REFERENCES Employee(id_employee),
  FOREIGN KEY (id_user)       REFERENCES `User`(id_user),
  FOREIGN KEY (id_promotions) REFERENCES Promotion(id_promotions)
);

-- PK เป็นรหัสประสม และ id_bill เปลี่ยนเป็น VARCHAR ให้ตรงกับ Bill
CREATE TABLE Basket (
  id_basket   VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
  id_branch   BIGINT NOT NULL,
  id_bill     VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  id_product  BIGINT NOT NULL,
  volume      DECIMAL(12,2) NOT NULL DEFAULT 1,
  price       DECIMAL(12,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (id_branch)  REFERENCES Branch(id_branch),
  FOREIGN KEY (id_bill)    REFERENCES Bill(id_bill),
  FOREIGN KEY (id_product) REFERENCES Product(id_product)
);

CREATE TABLE Message_Box (
  id_message_box BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_business    BIGINT NOT NULL,
  `date`         DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_business) REFERENCES Business(id_business)
);

CREATE TABLE Message_AI (
  id_message_ai  BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_message_box BIGINT NOT NULL,
  `role`         VARCHAR(20) NOT NULL,            -- user / assistant / system
  content        LONGTEXT,
  ai_model       VARCHAR(100),
  `date`         DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_message_box) REFERENCES Message_Box(id_message_box)
);

CREATE TABLE Ai_Active (
  id_ai_active   BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_message_ai  BIGINT NOT NULL,
  tool_name      VARCHAR(100),
  arguments      JSON,
  `result`       JSON,
  error_message  TEXT,
  target_id      BIGINT,
  target_table   VARCHAR(100),
  status         VARCHAR(20),
  `date`         DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_message_ai) REFERENCES Message_AI(id_message_ai)
);
