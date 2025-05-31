class Networkutility {
  static String baseUrl = "https://seekhelp.in/krivisha/";
  static String loginApiUrl = "${baseUrl}get_app_login";
  static String taskListApiUrl = "${baseUrl}get_all_manual_task_list_api";
  static String autoTaskListApiUrl = "${baseUrl}get_all_auto_task_list_api";
  static String departmentApiUrl = "${baseUrl}get_all_department_api";
  static String employeeApiUrl =
      "${baseUrl}get_employee_according_department_api";
  static String updateTaskApiUrl = "${baseUrl}set_update_manual_task_api";
  // Added new endpoint
  static String getEmployeeAccordingDepartment =
      "${baseUrl}get_employee_according_department_api";
  static int getEmployeeAccordingDepartmenttApi = 7;
  static String setManualTask = "${baseUrl}set_manual_task_api";
  static String getAllParty = "${baseUrl}get_all_party_details_api";
  static int getAllPartyApi = 9;
  static String getAllDepartment = "${baseUrl}get_all_department_api";
  static int getAllDepartmentApi = 10;
  static String getOrderList = "${baseUrl}get_all_order_list_api";

  static int getOrderListApi = 11;
  static String getMaintainanceApi = "${baseUrl}get_all_maintenance_list_api";
  static String getAllPlant = "${baseUrl}get_all_plant_api";
  static String getSubcategoryMaintenanceApi =
      "${baseUrl}get_subcategory_according_maintenance_api"; // Added subcategory API endpoint
  static String getDetailsAsPer = "${baseUrl}get_all_sub_types_problems_api";
  static String setMaintainanceApi = "${baseUrl}set_maintenance_data_api";
  static String getallVehicle = "${baseUrl}get_all_own_vehicle_api";
  static String getallLocations = "${baseUrl}get_all_location_api";
  static String setOwnvehicle = "${baseUrl}set_own_vehicle_data_api";
  static String getallOwnvehicleLIst = "${baseUrl}get_all_own_vehicle_list_api";

  static int getallOwnvehicleLIstApi = 12;
  static String getallPrintingReportlist =
      "${baseUrl}get_all_printing_order_list_api";
  static String getPartyOrderList = "${baseUrl}get_all_party_history_api";
    static String getAllArticleGroup = "${baseUrl}get_all_article_group_api";
  static String getAllArticleAcordingGroup =
      "${baseUrl}get_article_according_group_api";
       static String getBrandsApiList = "${baseUrl}get_brands_according_party_api";
  static int getallPrintingReportlistApi = 13;
  static int setManualTaskApi = 8;
  static int loginApi = 1;
  static int taskListApi = 2;
  static int autoTaskListApi = 3;
  static int departmentApi = 4;
  static int employeeApi = 5;
  static int updateTaskApi = 6; // Added new API identifier
}
