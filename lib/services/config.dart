// const BASE_URL = 'http://localhost:8080/api/'; //QA
const BASE_URL = 'http://10.72.24.149:8080/api/'; //QA

//Logifreight
const IOS_APP_VERSION = '1.0.0';

const POST_LOGIN_DETAILS = "auth/login";
const REGISTER_USER = "auth/register";

const CREATE_ORDER = "order/orders";
const GET_ORDERS = "order/orders";

const GET_ORDER_BY_ID = "order/orders/";

const GET_SCANNED_DATA = "transaction/mark-processed/";

const API_LOGOUT = "login/logout";
const POST_DRIVER_OTP = "login/validateOTP";

const GET_DASHBOARD_COUNTS = "dashboard/getTripsReport"; //Dashboard count
const DASHBOARD_SEARCH = "dashboard/search"; //Dashboard search

const GET_USER_CURRENT_LOCATION = "trip/getCurrentLocation?tripId=";

const GET_CUSTOMERS_LIST_BY_SEARCH =
    "indent/getCustomerBySearch"; //Indent-Customer list
const GET_CONSIGNOR_LIST_BY_SEARCH =
    "indent/getConsignorBySearch"; //Indent-Consignor list
const GET_CONSIGNEE_LIST_BY_SEARCH =
    "indent/getConsigneeBySearch"; //Indent-Consignee list
const GET_SERVICES_LIST = "indent/getServices"; //Indent-Services list
const GET_VEHICLE_TYPES_LIST =
    "/indent/getVehicleTypes"; //Indent-Vehicle Types list
const GET_PRODUCT_LIST_BY_SEARCH =
    "indent/getProductListBySearch"; //Indent-Product list
const CREATE_INDENT = "indent/create"; //create

const GET_ALL_INDENTS = "indent/getAll"; //indent list
const GET_INDENT_DETAILS_BY_ID =
    "indent/getById?indentId="; //indent details by id
const GET_INDENT_LR_DETAILS_BY_ID =
    "indent/getIndentLrDetails?indentId="; //indent details by id after submit

const DELETE_INDENT_BY_ID = "/indent/deleteById?indentId="; //indent delete
const UPDATE_INDENT = "/indent/update"; //indent update

const SAVE_PRIMARY_INDENT_DETAILS =
    "/indent/save"; //indent primary details for save/update
const SAVE_SEONDARY_INDENT_DETAILS =
    "/indent/saveIndentDetails"; //indent secondary details for save/update
const SUBMIT_INDENT =
    "/indent/createTrip"; //submit api to create with logifreight

const DELETE_INDENT_ITEM_BY_ID =
    "/indent/deleteItemById?indentId="; //indent item delete (consignor,consignee,products,etc) //second screen

//vehicle-driver mapping
const GET_DRIVERS_LIST = "/trip/getDrivers?driver="; //drivers list
const GET_VEHICLES_LIST = "/trip/getVehicles?vehicleNo="; //vehicles list
const GET_GPS_DEVICES_LIST =
    "/trip/getGpsDevices?deviceName="; //GPS Devices list

//trips list screen based on status
const GET_PENDING_ASSIGNMENT_LIST =
    "/dashboard/getNoVehiclePlacedList"; //pending assignment
const GET_READY_TO_PICKUP_LIST =
    "/dashboard/getReadyToPickUpList"; //ready to pickup
const GET_INTRANSIT_LIST = "dashboard/getDispatchedList"; //dispatched
const GET_DELIVERED_LIST = "/dashboard/getDeliveredList"; //delivered

const ALLOCATE_DRIVER_VEHICLE_IN_TRIP =
    "/trip/updateTripDetails"; //allocate D,V

const GET_INVOICE_DETAILS =
    "trip/getInvoiceDetails?ewayBillNumber="; //driver flow get invoice
const SAVE_INVOICE_DETAILS = "trip/updateInvoiceDetails";

const DOWNLOAD_DRIVER_INVOICE_PDF = "trip/downloadInvoice?tripId=";
const EPOD_DOWNLOAD_API = "dashboard/getDownloadUrl?lrNumber=";

const DOWNTIME_CHECK = "/user/downtime";
