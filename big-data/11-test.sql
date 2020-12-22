DROP TABLE IF EXISTS employee;

CREATE TABLE IF NOT EXISTS employee (
    `id` INT(20) PRIMARY KEY COMMENT 'ID',
    `name` VARCHAR(20) NOT NULL COMMENT '姓名',
    `salary` DOUBLE COMMENT '工资',
    `department` VARCHAR(20) COMMENT '部门名称',
    `email` VARCHAR(30) COMMENT '电子邮件地址',
    `last_update` DATETIME COMMENT '最后更新时间'
)
COMMENT '员工表';

INSERT INTO employee(`id`, `name`, `salary`, `department`, `email`, `last_update`) VALUES (1, '应卓', 27000, '研发部', 'yingzhor@gmail.com', NOW());
INSERT INTO employee(`id`, `name`, `salary`, `department`, `email`, `last_update`) VALUES (2, '刘贺龙', 18000, '研发部', NULL, NOW());
INSERT INTO employee(`id`, `name`, `salary`, `department`, `email`, `last_update`) VALUES (3, '刘广亚', 18000, '研发部', NULL, NOW());
INSERT INTO employee(`id`, `name`, `salary`, `department`, `email`, `last_update`) VALUES (4, '刘星玉', 15000, '研发部', NULL, NOW());
INSERT INTO employee(`id`, `name`, `salary`, `department`, `email`, `last_update`) VALUES (5, '邓俊', 17000, '研发部', NULL, NOW());
INSERT INTO employee(`id`, `name`, `salary`, `department`, `email`, `last_update`) VALUES (6, '王莽', 17000, '研发部', NULL, NOW());
