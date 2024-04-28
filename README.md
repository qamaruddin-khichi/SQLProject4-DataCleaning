# Data Cleaning with MySQL: Layoffs Dataset

## Table of Contents
1. [About](#about)
2. [Purpose of Project](#purpose-of-project)
3. [SQL Code](#sql-code)
4. [Conclusion](#conclusion)

## About

This project focuses on data cleaning using MySQL, specifically addressing issues within the layoffs dataset sourced from Kaggle. The dataset contains information about layoffs in various companies across different industries. The project aims to clean and standardize the data to ensure its accuracy and reliability for further analysis.

## Purpose of Project

The primary purpose of this project is to clean and standardize the layoffs dataset to prepare it for analysis. By addressing issues such as duplicates, errors, and inconsistencies within the data, the project aims to improve data quality and integrity. The cleaned dataset can then be used for various analytical purposes, including trend analysis, predictive modeling, and decision-making processes.

## SQL Code

```sql
-- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

USE world_layoffs;

-- Data Cleaning

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Checking for duplicates and removing them
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY company, industry, total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging; 

WITH duplicate_cte AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY company, industry, total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY company, industry, total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging; 

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data

-- Company column
UPDATE layoffs_staging2
SET company =  TRIM(company);

-- Industry column
UPDATE layoffs_staging2
SET industry =  'Crypto'
WHERE industry LIKE 'Crypto%';

-- Country column
UPDATE layoffs_staging2
SET country =  TRIM(TRAILING '.'FROM country)
WHERE country LIKE 'United States%';

-- Date column
UPDATE layoffs_staging2
SET `date` =  STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

UPDATE layoffs_staging2 T1
JOIN layoffs_staging2 T2
ON T1.company = T2.company
SET T1.industry = T2.industry
WHERE T1.industry IS NULL
AND T2.industry IS NOT NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;
```

## Conclusion

This project demonstrates the importance of data cleaning in preparing datasets for analysis. By systematically addressing issues such as duplicates, errors, and inconsistencies within the layoffs dataset, the project ensures that the data is accurate, reliable, and ready for further analysis. The cleaned dataset can now be used with confidence for various analytical purposes, providing valuable insights into layoffs trends.
