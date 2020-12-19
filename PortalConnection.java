package portal;


import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/portal";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "shawncooper";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){

      String outcome;
      String registerString = "INSERT INTO Registrations VALUES (?, ?)";
      
      try (PreparedStatement registerStudent = conn.prepareStatement(registerString);){
          registerStudent.setString(1, student);
          registerStudent.setString(2, courseCode);
          registerStudent.executeUpdate();
          outcome = "{\"success\": true}";
          return outcome;
      } catch (SQLException e) {
          outcome = "{\"success\":false, \"error\":\""+ getError(e) +"\"}";
        return outcome;
      }    
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){

      String outcome;
      String unregisterString = "DELETE FROM Registrations WHERE student=? AND course=?";

      try (PreparedStatement unregisterStudent = conn.prepareStatement(unregisterString);){
          unregisterStudent.setString(1, student);
          unregisterStudent.setString(2, courseCode);
          int rs = unregisterStudent.executeUpdate();

          if (rs == 0){
        	  throw new SQLException("Student cannot unregister on course it's not registered on");
//        	  outcome = "{\"success\":false, \"error\": Student cannot unregister on course it's not registered on}";
          }
          else{
        	  outcome = "{\"success\": true}"; 
          }
          return outcome;
          
      } catch (SQLException e) {
          outcome = "{\"success\":false, \"error\":\""+ getError(e) +"\"}";
        return outcome;
      }
    }
    
    public String unregister_sql_injection(String student, String courseCode){

        String outcome;
        String unregisterString = "DELETE FROM Registrations WHERE student = '"
      		  					+ student +"' AND course = '" + courseCode + "'";

        try (PreparedStatement unregisterStudent = conn.prepareStatement(unregisterString);){

            
            unregisterStudent.executeUpdate();
            outcome = "{\"success\": true}";
            return outcome;
        } catch (SQLException e) {
            outcome = "{\"success\":false, \"error\":\""+ getError(e) +"\"}";
          return outcome;
        }
      }

    // Return a JSON document containing lots of information about a student, 
    // it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
            "SELECT jsonb_build_object(\n"
            + "	'student', idnr, \n"
            + "	'name', name, \n"
            + "	'login', login, \n"
            + "	'program', program, \n"
            + "	'branch', branch,\n"
            + "	'finished', (SELECT COALESCE(jsonb_agg(jsonb_build_object(\n"
            + "		'course', (SELECT name FROM Courses WHERE code=F.course), \n"
            + "		'code', course,\n"
            + "		'credits', credits,\n"
            + "		'grade', grade)\n"
            + "	),'[]') FROM FinishedCourses F WHERE student=B.idnr),\n"
            + "	'registered', (SELECT COALESCE(jsonb_agg(jsonb_build_object(\n"
            + "		'course', (SELECT name FROM Courses WHERE code=R.course),\n"
            + "		'code', course,\n"
            + "		'status', status,\n"
            + "		'position', (SELECT place FROM CourseQueuePositions WHERE student=B.idnr AND course=R.course))\n"
            + "	),'[]') FROM Registrations R WHERE student=B.idnr),\n"
            + "	'seminarCourses', (SELECT seminarCourses FROM PathToGraduation WHERE student=B.idnr),\n"
            + "	'mathCredits', (SELECT mathCredits FROM PathToGraduation WHERE student=B.idnr),\n"
            + "    'researchCredits', (SELECT researchCredits FROM PathToGraduation WHERE student=B.idnr),\n"
            + "    'totalCredits', (SELECT totalCredits FROM PathToGraduation WHERE student=B.idnr),\n"
            + "    'canGraduate', (SELECT qualified FROM PathToGraduation WHERE student=B.idnr)\n"
            + "	) AS jsondata\n"
            + "FROM BasicInformation B\n"
            + "WHERE idnr=?;"
            );){
            
            st.setString(1, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}