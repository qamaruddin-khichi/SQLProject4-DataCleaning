-- Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

USE world_layoffs;

-- Data Cleaning

SELECT *
FROM layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

/* Now, when we are cleaning data, we usually follow a few steps

 1. Checking duplicates and removing them
 2. Standardize data and fix errors
 3. Look at null values
 4. Remove any columns and rows which are not necessary */

-- There is no any ID_Num or anything like that, so first of all make that

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
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

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
  `funds_raised` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY company, industry, total_laid_off,percentage_laid_off,`date`) AS row_num
FROM layoffs_staging; 

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardize Data

-- Company column
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company =  TRIM(company);

-- Industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry =  'Crypto'
WHERE industry LIKE 'Crypto%';

-- Country column
SELECT DISTINCT country, TRIM(TRAILING '.'FROM country)
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country =  TRIM(TRAILING '.'FROM country)
WHERE country LIKE 'United States%';

-- Date column
SELECT 	`date`,
		STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` =  STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT T1.industry, T2.industry
FROM layoffs_staging2 T1
JOIN layoffs_staging2 T2
ON T1.company = T2.company
WHERE (T1.industry IS NULL OR T1.industry = '')
AND T2.industry IS NOT NULL;

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