1. Customers isimli bir veritabanı oluşturunuz ve içerisine verilen excel dosyasını tablo olarak ekleyin.

SELECT * FROM CUSTOMERS
SELECT * FROM CITIES
SELECT * FROM DISTRICTS

2. Customers tablosundan adı ‘A’ harfi ile başlayan kişileri çeken sorguyu yazınız.

SELECT * 
FROM CUSTOMERS
WHERE NAMESURNAME LIKE 'A%';

3. 1990 ve 1995 yılları arasında doğan müşterileri çekiniz. 1990 ve 1995 yılları dahildir.

SELECT * 
FROM CUSTOMERS
WHERE BIRTHDATE BETWEEN '1990-01-01' AND '1995-12-31';


4. İstanbul’da yaşayan kişileri Join kullanarak getiren sorguyu yazınız.

SELECT C.*,CT.CITY FROM CUSTOMERS C
 INNER JOIN CITIES CT ON C.CITYID = CT.ID
 WHERE CT.CITY = 'İSTANBUL'

5. İstanbul’da yaşayan kişileri subquery kullanarak getiren sorguyu yazınız

SELECT * FROM CUSTOMERS
WHERE CITYID = ( SELECT ID
				FROM CITIES
				WHERE CITY = 'İstanbul');

6. Hangi şehirde kaç müşterimizin olduğu bilgisini getiren sorguyu yazınız.

SELECT (SELECT CITY FROM CITIES WHERE ID = c.CITYID) AS City, COUNT(*) AS Number_of_customers
FROM CUSTOMERS c
GROUP BY CITYID
ORDER BY Number_of_customers DESC;


7. 10’dan fazla müşterimiz olan şehirleri müşteri sayısı ile birlikte müşteri sayısına göre fazladan aza doğru sıralı şekilde getiriniz

1)SELECT CT.CITY, COUNT(C.ID) AS TOTAL_CUSTOMERS
FROM CUSTOMERS C
JOIN CITIES CT ON C.CITYID = CT.ID
GROUP BY CT.CITY
HAVING COUNT(C.ID) > 10
ORDER BY TOTAL_CUSTOMERS DESC;

2)SELECT*,
(SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID=C.ID)
FROM CITIES C
WHERE (SELECT COUNT(*) FROM CUSTOMERS WHERE CITYID=C.ID) >10

8. Hangi şehirde kaç erkek, kaç kadın müşterimizin olduğu bilgisini getiren sorguyu yazınız

SELECT 
    CITYID,
    SUM(CASE WHEN GENDER = 'E' THEN 1 ELSE 0 END) AS total_mannlich_kunden,
    SUM(CASE WHEN GENDER = 'K' THEN 1 ELSE 0 END) AS total_weiblich_kunden,
    COUNT(*) AS total_kunden
FROM CUSTOMERS
GROUP BY CITYID
ORDER BY CITYID;

9. Customers tablosuna yaş grubu için yeni bir alan ekleyiniz. Bu işlemi hem management studio ile hem de sql
kodu ile yapınız. Alanı adı AGEGROUP veritipi Varchar(50)

ALTER TABLE CUSTOMERS 
ADD AGEGROUP VARCHAR (50)

10. Customers tablosuna eklediğiniz AGEGROUP alanını 20-35 yaş arası,36-45 yaş arası,46-55 yaş arası,55-65 yaş
arası ve 65 yaş üstü olarak güncelleyiniz.

UPDATE CUSTOMERS
SET AGEGROUP =
    CASE 
        WHEN DATEDIFF(YEAR, BIRTHDATE, GETDATE()) BETWEEN 20 AND 35 THEN '20-35 Jahre alt'
        WHEN DATEDIFF(YEAR, BIRTHDATE, GETDATE()) BETWEEN 36 AND 45 THEN '36-45 Jahre alt'
        WHEN DATEDIFF(YEAR, BIRTHDATE, GETDATE()) BETWEEN 46 AND 55 THEN '46-55 Jahre alt'
        WHEN DATEDIFF(YEAR, BIRTHDATE, GETDATE()) BETWEEN 56 AND 65 THEN '56-65 Jahre alt'
        WHEN DATEDIFF(YEAR, BIRTHDATE, GETDATE()) > 65 THEN 'über 65'
        ELSE 'Nicht spezifiziert'
    END;

SELECT * FROM CUSTOMERS
11. İstanbul’da yaşayıp ilçesi ‘Kadıköy’ dışında olanları listeleyiniz.

SELECT * FROM DISTRICTS
WHERE CITYID = '34' 
  AND DISTRICT <>'Kadıköy';

12. Müşterilerimizin telefon numalarının operatör bilgisini getirmek istiyoruz. TELNR1 ve TELNR2 alanlarının yanına
operatör numarasını (532),(505) gibi getirmek istiyoruz. Bu sorgu için gereken SQL cümlesini yazınız.

SELECT 
    ID,
    NAMESURNAME,
    TELNR1,
    CASE WHEN TELNR1 IS NOT NULL THEN CONCAT('(', LEFT(TELNR1, 4), ')') ELSE NULL END AS 'Initial three numbers',
    TELNR2,
    CASE WHEN TELNR2 IS NOT NULL THEN CONCAT('(', LEFT(TELNR2, 4), ')') ELSE NULL END AS 'Initial three numbers'
FROM CUSTOMERS;

13. Müşterilerimizin telefon numaralarının operatör bilgisini getirmek istiyoruz. Örneğin telefon numaraları “50”
ya da “55” ile başlayan “X” operatörü “54” ile başlayan “Y” operatörü “53” ile başlayan “Z” operatörü olsun.
Burada hangi operatörden ne kadar müşterimiz olduğu bilgisini getirecek sorguyu yazınız.

SELECT 
    CASE 
        WHEN LEFT(TELNR1, 3) IN ('(50', '(55') THEN 'X Operatörü'
        WHEN LEFT(TELNR1, 3) = '(54' THEN 'Y Operatörü'
        WHEN LEFT(TELNR1, 3) = '(53' THEN 'Z Operatörü'
        ELSE 'Diğer Operatörler'
    END AS Operator,
    COUNT(*) AS MusteriSayisi
FROM CUSTOMERS
WHERE TELNR1 IS NOT NULL
GROUP BY 
    CASE 
        WHEN LEFT(TELNR1, 3) IN ('(50', '(55') THEN 'X Operatörü'
        WHEN LEFT(TELNR1, 3) = '(54' THEN 'Y Operatörü'
        WHEN LEFT(TELNR1, 3) = '(53' THEN 'Z Operatörü'
        ELSE 'Diğer Operatörler'
    END

14. Her ilde en çok müşteriye sahip olduğumuz ilçeleri müşteri sayısına göre çoktan aza doğru sıralı şekilde
şekildeki gibi getirmek için gereken sorguyu yazınız.

WITH DistrictCounts AS (
    SELECT 
        CITYID,
        DISTRICT,
        COUNT(*) AS CustomerCount,
        ROW_NUMBER() OVER (PARTITION BY CITYID ORDER BY COUNT(*) DESC) AS rn
    FROM CUSTOMERS
    GROUP BY CITYID, DISTRICT
)
SELECT 
    CITYID,
    DISTRICT,
    CustomerCount
FROM DistrictCounts
WHERE rn = 1
ORDER BY CustomerCount DESC;

15. Müşterilerin doğum günlerini haftanın günü(Pazartesi, Salı, Çarşamba..) olarak getiren sorguyu yazınız.

SELECT 
	ID,
    NAMESURNAME,
    BIRTHDATE,
    DATENAME(WEEKDAY, BIRTHDATE) AS Geburstag
FROM 
    CUSTOMERS
WHERE 
    BIRTHDATE IS NOT NULL;