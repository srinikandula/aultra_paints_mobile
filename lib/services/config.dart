// const BASE_URL = 'http://localhost:8080/api/'; //QA
// const BASE_URL = 'http://192.168.1.4:4300/api/'; //QA

const BASE_URL = 'https://api.aultrapaints.com/api/'; //Admin
// const BASE_URL = 'https://mapp.aultrapaints.com/api/'; //QA

const IOS_APP_VERSION = '1.0.0';

const POST_SEND_LOGIN_OTP = "auth/loginWithOTP"; //send otp
const POST_VERIFY_LOGIN_OTP = "auth/verifyOTP"; //verify otp
const POST_LOGIN_DETAILS = "auth/login"; //login
const REGISTER_USER = "auth/register"; //signup

const GET_USER_DETAILS = "users/getUser/"; //dashboard

const GET_DEALERS = "users/getDealers";

const GET_USER_DEALER = "users/getUserDealer/";

const GET_USER_PARENT_DEALER_CODE_DETAILS = "users/getParentDealerCodeUser";

const VERIFY_OTP_UPDATE_USER = "users/verifyOtpUpdateUser";

const TRANSFER_TO_DEALER = "transfer/toDealer";

const CREATE_ORDER = "order/orders";

const GET_ORDERS = "order/orders";

const GET_ORDER_BY_ID = "order/orders/";

const GET_SCANNED_DATA = "transaction/mark-processed/"; //old
const POST_SCANNED_DATA = "transaction/redeemPoints"; //new api with POST

const GET_PRODUCT_OFFERS = "productOffers/getProductOffers";

const GET_MY_PAINTERS = "users/getMyPainters";

const GET_TRANSACTION_LEDGER = "transactionLedger/getTransactions";

const GET_REWARDS_SCHEMES = "rewardSchemes/getRewardSchemes";

const API_LOGOUT = "login/logout";

// const DELETE_USER_ACCOUNT = "api/users/userAccountSuspended/";
const DELETE_USER_ACCOUNT = "users/toggle-status/";
