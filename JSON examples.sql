-- Beginner Level
BEGIN
  -- Declare a variable with JSON data
  DECLARE @jsonData NVARCHAR(MAX) = N'{"name": "John", "age": 30, "city": "New York"}';

  -- Extract values from JSON using JSON functions
  DECLARE @name NVARCHAR(50), @age INT, @city NVARCHAR(50);

  SET @name = JSON_VALUE (@jsonData, '$.name');
  SET @age = JSON_VALUE (@jsonData, '$.age');
  SET @city = JSON_VALUE (@jsonData, '$.city');

  -- Display the extracted values
  PRINT 'Name: ' + @name;
  PRINT 'Age: ' + CAST (@age AS NVARCHAR(10));
  PRINT 'City: ' + @city;
END;

-- Intermediate Level
BEGIN
  -- Declare a variable with JSON array
  DECLARE @jsonArray NVARCHAR(MAX)
    = N'[{"name": "John", "age": 30}, {"name": "Jane", "age": 25}, {"name": "Bob", "age": 35}]';

  -- Declare variables for calculations
  DECLARE @totalAge INT = 0, @personCount INT = 0;

  -- Create a temporary table variable to store extracted values
  DECLARE @tempTable TABLE (Name NVARCHAR(50), Age INT);

  -- Insert JSON array values into the temporary table
  INSERT INTO @tempTable (Name, Age)
  SELECT JSON_VALUE (value, '$.name') AS Name, CAST (JSON_VALUE (value, '$.age') AS INT) AS Age
    FROM OPENJSON (@jsonArray);

  -- Iterate over the temporary table and perform calculations
  DECLARE @currentName NVARCHAR(50), @currentAge INT;
  DECLARE personCursor CURSOR FOR SELECT Name, Age FROM @tempTable;
  OPEN personCursor;

  FETCH NEXT FROM personCursor
   INTO @currentName, @currentAge;
  WHILE @@fetch_status = 0
    BEGIN
      -- Perform operations with each person
      PRINT 'Processing: ' + @currentName + ', Age: ' + CAST (@currentAge AS NVARCHAR(10));

      -- Accumulate age for average calculation
      SET @totalAge = @totalAge + @currentAge;
      SET @personCount = @personCount + 1;

      FETCH NEXT FROM personCursor
       INTO @currentName, @currentAge;
    END;

  CLOSE personCursor;
  DEALLOCATE personCursor;

  -- Calculate and display the average age
  DECLARE @averageAge FLOAT;
  IF @personCount > 0
    BEGIN
      SET @averageAge = CAST (@totalAge AS FLOAT) / @personCount;
      PRINT 'Average Age: ' + CAST (@averageAge AS NVARCHAR(10));
    END;
  ELSE BEGIN
PRINT 'No persons in the array.';
    END;
END;

-- Expert Level
BEGIN
  -- Declare a variable with JSON document
  DECLARE @jsonOrgStructure NVARCHAR(MAX)
    = N'{"companyName": "TechCo",
	 		 "departments": [
				 {
					 "name": "Development",
					 "employees": [
						 {"name": "John", "position": "Developer", "salary": 80000},
						 {"name": "Jane", "position": "Senior Developer", "salary": 100000}
					 ]
				 },
				 {
					 "name": "Sales",
					 "employees": [
						 {"name": "Bob", "position": "Sales Representative", "salary": 75000},
						 {"name": "Alice", "position": "Sales Manager", "salary": 90000}
					 ]
				 }
			 ]
		    }';

  -- Get company name
  DECLARE @companyName NVARCHAR(50) = JSON_VALUE (@jsonOrgStructure, '$.companyName');
  PRINT 'Company Name: ' + @companyName;

  -- Get the count of departments
  DECLARE @departmentCount INT = ISNULL ((SELECT COUNT (*) FROM OPENJSON (@jsonOrgStructure, '$.departments')), 0);
  PRINT 'Number of Departments: ' + CAST (@departmentCount AS NVARCHAR(10));

  -- Iterate over departments
  DECLARE @departmentIndex INT = 0;

  WHILE @departmentIndex < @departmentCount
    BEGIN
      DECLARE @departmentName NVARCHAR(50);
      DECLARE @employees NVARCHAR(MAX);

      -- Get department name
      SET @departmentName
        = JSON_VALUE (@jsonOrgStructure, '$.departments[' + CAST (@departmentIndex AS NVARCHAR(10)) + '].name');
      PRINT 'Department: ' + @departmentName;

      -- Get employees in the department
      SET @employees
        = JSON_QUERY (@jsonOrgStructure, '$.departments[' + CAST (@departmentIndex AS NVARCHAR(10)) + '].employees');

      -- Count employees in the department
      DECLARE @employeeCount INT = ISNULL ((SELECT COUNT (*) FROM OPENJSON (@employees)), 0);
      PRINT 'Employee Count: ' + CAST (@employeeCount AS NVARCHAR(10));

      -- Print employee information
      IF @employeeCount > 0
        BEGIN
          PRINT 'Employees:';
          DECLARE @jsonResult NVARCHAR(MAX);

          SET @jsonResult = ( SELECT [name], [position], [salary]
                                FROM
                                OPENJSON (@employees)
                                  WITH ([name] NVARCHAR (50), [position] NVARCHAR (50), [salary] INT) AS employee
                              FOR JSON PATH);

          -- Replace commas between objects with newline characters
          SET @jsonResult = REPLACE (@jsonResult, '},{', '},' + CHAR (13) + CHAR (10) + '{');

          PRINT @jsonResult;
        END;
      ELSE BEGIN
PRINT 'No employees in this department.';
        END;

      PRINT ''; -- Add a line break between departments
      SET @departmentIndex = @departmentIndex + 1;
    END;
END;

-- God Mode Level
BEGIN
  DECLARE @jsonOrgStructure NVARCHAR(MAX)
    = N'{
    "companyName": "TechCo",
    "departments": [
        {
            "name": "Development",
            "employees": [
                {"name": "John", "position": "Developer", "salary": 80000},
                {"name": "Jane", "position": "Senior Developer", "salary": 100000}
            ]
        },
        {
            "name": "Sales",
            "employees": [
                {"name": "Bob", "position": "Sales Representative", "salary": 75000},
                {"name": "Alice", "position": "Sales Manager", "salary": 90000}
            ]
        }
    ]
}';

  -- Get company name
  DECLARE @companyName NVARCHAR(50) = JSON_VALUE (@jsonOrgStructure, '$.companyName');
  PRINT 'Company Name: ' + @companyName;

  -- Get the count of departments
  DECLARE @departmentCount INT = ISNULL ((SELECT COUNT (*) FROM OPENJSON (@jsonOrgStructure, '$.departments')), 0);
  PRINT 'Number of Departments: ' + CAST (@departmentCount AS NVARCHAR(10));

  -- Iterate over departments
  DECLARE @departmentIndex INT = 0;

  WHILE @departmentIndex < @departmentCount
    BEGIN
      DECLARE @departmentName NVARCHAR(50);
      DECLARE @employees NVARCHAR(MAX);

      -- Get department name
      SET @departmentName
        = JSON_VALUE (@jsonOrgStructure, '$.departments[' + CAST (@departmentIndex AS NVARCHAR(10)) + '].name');
      PRINT 'Department: ' + @departmentName;

      -- Get employees in the department
      SET @employees
        = JSON_QUERY (@jsonOrgStructure, '$.departments[' + CAST (@departmentIndex AS NVARCHAR(10)) + '].employees');

      -- Count employees in the department
      DECLARE @employeeCount INT = ISNULL ((SELECT COUNT (*) FROM OPENJSON (@employees)), 0);
      PRINT 'Employee Count: ' + CAST (@employeeCount AS NVARCHAR(10));

      -- Print employee information with detailed salary breakdown
      IF @employeeCount > 0
        BEGIN
          PRINT 'Detailed Employee Information:';
          DECLARE @jsonResult NVARCHAR(MAX);

          SET @jsonResult = ( SELECT emp.name,
                                     emp.position,
                                     emp.salary,
                                     CASE
                                       WHEN emp.salary >= 100000 THEN 'High Salary'
                                       WHEN emp.salary >= 80000 THEN 'Mid Salary'
                                       ELSE 'Low Salary'
                                     END AS SalaryBreakdown
                                FROM OPENJSON (@employees)
                               CROSS APPLY
                                OPENJSON (value)
                                  WITH ([name] NVARCHAR (50), [position] NVARCHAR (50), [salary] INT) AS emp
                              FOR JSON PATH);

          -- Replace commas between objects with newline characters
          SET @jsonResult = REPLACE (@jsonResult, '},{', '},' + CHAR (13) + CHAR (10) + '{');

          PRINT @jsonResult;
        END;
      ELSE BEGIN
PRINT 'No employees in this department.';
        END;

      PRINT ''; -- Add a line break between departments
      SET @departmentIndex = @departmentIndex + 1;
    END;
END;
