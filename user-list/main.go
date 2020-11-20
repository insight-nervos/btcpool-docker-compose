package main

import (
  "strconv"
  "net/http"
  "encoding/json"
  "os"
  "io/ioutil"
  "encoding/json"
)

var miners map[string]int

func main() {

  // read json file for default miners 
  miner_json_path := "./config/miners.json"

  miner_json, err := os.Open(miner_json_path)
  if err != nil {
    panic(err)
  }
  defer miner_json.Close()

  json_bytes, _ := ioutil.ReadAll(miner_json)
  json.Unmarshal(json_bytes, &miners)

  // http server
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

  requested_miners := map[string]int{}
  for miner, id := range miners {
    if (id > last_id) {
      requested_miners[miner] = id
    }
  }

  resp := map[string]interface{}{}

  resp["err_no"] = 0
  resp["err_msg"] = nil
  resp["data"] = requested_miners

  resp_json, _ := json.Marshal(resp)
  w.Write(resp_json)
}
