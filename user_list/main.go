package main

import (
    "strconv"
    "net/http"
    "encoding/json"
)

func main() {
    http.HandleFunc("/userlist.php", GetUserList)
    http.ListenAndServe(":8000", nil)
}

func GetUserList(w http.ResponseWriter, r *http.Request) {
  last_id_str, _ := r.URL.Query()["last_id"]

  var last_id int
  if (len(last_id_str) == 0) {
    last_id = 0
  } else{
    last_id, _ = strconv.Atoi(last_id_str[0])
  }

  users := map[string]int{
    "aaa": 1,
    "bbb": 2,
    "xxx": 3,
    "mmm": 4,
    "vvv": 5,
    "ddd": 6,
  }

  requested_users := map[string]int{}
  for user, id := range users {
    if (id > last_id) {
      requested_users[user] = id
    }
  }

  resp := map[string]interface{}{}

  resp["err_no"] = 0
  resp["err_msg"] = nil
  resp["data"] = requested_users

  resp_json, _ := json.Marshal(resp)
  w.Write(resp_json)
}
