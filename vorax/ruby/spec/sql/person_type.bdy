CREATE TYPE BODY person_typ AS

	CONSTRUCTOR FUNCTION person_typ(SELF IN OUT NOCOPY shape, name VARCHAR2) 
															RETURN SELF AS RESULT IS
		l_local varchar2(100);

		function my_func(p1 boolean, p2 integer := (1+2)) return boolean as
		begin
			return false;
		end;

		l_muci integer;

	BEGIN
			SELF.name := name;
			SELF.area := 0;
			RETURN;
	END;
 
  MAP MEMBER FUNCTION get_idno RETURN NUMBER IS
  BEGIN
    RETURN idno;
  END;

  MEMBER PROCEDURE display_details ( SELF IN OUT NOCOPY person_typ ) IS
  BEGIN
    -- use the PUT_LINE procedure of the DBMS_OUTPUT package to display details
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(idno) || ' - '  || name || ' - '  || phone);
  END;

	ORDER MEMBER FUNCTION match (l location_typ) RETURN INTEGER IS 
  BEGIN 
    IF building_no < l.building_no THEN
      RETURN -1;               -- any negative number will do
    ELSIF building_no > l.building_no THEN 
      RETURN 1;                -- any positive number will do
    ELSE 
      RETURN 0;
    END IF;
  END;

  STATIC FUNCTION show_super (person_obj in person_typ) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'Id: ' || TO_CHAR(person_obj.idno) || ', Name: ' || person_obj.name;
  END;

  OVERRIDING MEMBER FUNCTION show RETURN VARCHAR2 IS
  BEGIN
    RETURN person_typ.show_super ( SELF ) || ' -- Major: ' || major ||
           ', Hours: ' || TO_CHAR(number_hours);
  END;
 
END;
/
