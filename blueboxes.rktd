3702
((3) 0 () 11 ((q lib "whatnow/db/db.rkt") (q lib "whatnow/server/forecast-json.rkt") (q 575 . 16) (q 334 . 7) (q lib "whatnow/config.rkt") (q 60 . 5) (q 1388 . 5) (q 1061 . 9) (q 1670 . 12) (q 1504 . 6) (q lib "whatnow/server/forecast.rkt")) () (h ! (equal) ((c def c (c (? . 10) q get-assignments)) q (2749 . 3)) ((c def c (c (? . 0) q client)) c (? . 6)) ((c def c (c (? . 4) q server-account-token)) c (? . 5)) ((c def c (c (? . 1) q get-people)) q (2977 . 3)) ((c def c (c (? . 0) q project?)) c (? . 7)) ((c def c (c (? . 0) q allocation)) c (? . 9)) ((c def c (c (? . 0) q schedule)) c (? . 3)) ((q def ((lib "whatnow/schedule.rkt") get-the-schedule)) q (2165 . 2)) ((c def c (c (? . 1) q get-clients)) q (3186 . 3)) ((c def c (c (? . 0) q person?)) c (? . 2)) ((c def c (c (? . 0) q person-id)) c (? . 2)) ((c def c (c (? . 0) q struct:schedule)) c (? . 3)) ((c def c (c (? . 4) q server-account?)) c (? . 5)) ((c def c (c (? . 0) q client?)) c (? . 6)) ((c def c (c (? . 0) q assignment-person-id)) c (? . 8)) ((c def c (c (? . 0) q project-harvest-id)) c (? . 7)) ((c def c (c (? . 0) q person-roles)) c (? . 2)) ((c def c (c (? . 0) q assignment)) c (? . 8)) ((c def c (c (? . 1) q get-projects)) q (3117 . 3)) ((c def c (c (? . 0) q schedule?)) c (? . 3)) ((c def c (c (? . 0) q project-client-id)) c (? . 7)) ((c def c (c (? . 0) q struct:allocation)) c (? . 9)) ((c def c (c (? . 1) q connect)) q (2831 . 5)) ((c def c (c (? . 0) q schedule-assignments)) c (? . 3)) ((c def c (c (? . 0) q schedule-programmes)) c (? . 3)) ((c def c (c (? . 0) q assignment-project-id)) c (? . 8)) ((c def c (c (? . 10) q get-team)) q (2516 . 3)) ((c def c (c (? . 0) q schedule-people)) c (? . 3)) ((c def c (c (? . 0) q assignment?)) c (? . 8)) ((c def c (c (? . 10) q connect)) q (2209 . 5)) ((c def c (c (? . 0) q person)) c (? . 2)) ((c def c (c (? . 10) q get-the-forecast-schedule)) q (2355 . 5)) ((c def c (c (? . 0) q project-name)) c (? . 7)) ((c def c (c (? . 0) q person-first-name)) c (? . 2)) ((c def c (c (? . 0) q project-id)) c (? . 7)) ((c def c (c (? . 0) q person-harvest-id)) c (? . 2)) ((c def c (c (? . 0) q client-name)) c (? . 6)) ((c def c (c (? . 0) q allocation?)) c (? . 9)) ((c def c (c (? . 0) q struct:client)) c (? . 6)) ((q def ((lib "whatnow/api/local-config.rkt") FORECAST-SERVER)) q (0 . 2)) ((c def c (c (? . 0) q person-login?)) c (? . 2)) ((c def c (c (? . 4) q config-get-accounts)) q (167 . 4)) ((c def c (c (? . 0) q allocation-end-date)) c (? . 9)) ((c def c (c (? . 0) q struct:project)) c (? . 7)) ((c def c (c (? . 0) q assignment-start-date)) c (? . 8)) ((c def c (c (? . 1) q get-placeholders)) q (3044 . 3)) ((c def c (c (? . 4) q server-account-id)) c (? . 5)) ((c def c (c (? . 0) q assignment-end-date)) c (? . 8)) ((c def c (c (? . 0) q assignment-allocation)) c (? . 8)) ((c def c (c (? . 0) q person-last-name)) c (? . 2)) ((c def c (c (? . 4) q server-account)) c (? . 5)) ((c def c (c (? . 0) q allocation-rate)) c (? . 9)) ((c def c (c (? . 0) q person-email)) c (? . 2)) ((c def c (c (? . 0) q allocation<?)) q (2056 . 4)) ((c def c (c (? . 4) q struct:server-account)) c (? . 5)) ((c def c (c (? . 0) q project-code)) c (? . 7)) ((c def c (c (? . 0) q allocation-start-date)) c (? . 9)) ((c def c (c (? . 0) q struct:person)) c (? . 2)) ((c def c (c (? . 10) q get-projects)) q (2591 . 3)) ((c def c (c (? . 1) q get-assignments)) q (3254 . 3)) ((c def c (c (? . 0) q project)) c (? . 7)) ((c def c (c (? . 0) q schedule-projects)) c (? . 3)) ((c def c (c (? . 0) q client-id)) c (? . 6)) ((c def c (c (? . 0) q project-tags)) c (? . 7)) ((c def c (c (? . 0) q struct:assignment)) c (? . 8)) ((c def c (c (? . 10) q get-clients)) q (2671 . 3))))
value
FORECAST-SERVER : string? = "api.forecastapp.com"
struct
(struct server-account (id token)
    #:transparent)
  id : string?
  token : string?
procedure
(config-get-accounts [secret-file-name]) -> (listof
                                            pair?)
  secret-file-name : string? = "secrets.txt"
struct
(struct schedule (people projects programmes assignments)
    #:transparent)
  people : (listof person?)
  projects : (listof project?)
  programmes : (listof programme?)
  assignments : (listof assignment?)
struct
(struct person (id
                harvest-id
                first-name
                last-name
                email
                login?
                roles)
    #:transparent)
  id : exact-nonnegative-integer?
  harvest-id : (or/c #f exact-nonnegative-integer?)
  first-name : (or/c #f string?)
  last-name : (or/c #f string?)
  email : (or/c #f string?)
  login? : boolean?
  roles : (listof string?)
struct
(struct project (id harvest-id name code tags client-id)
    #:transparent)
  id : exact-nonnegative-integer?
  harvest-id : (or/c #f exact-nonnegative-integer?)
  name : string?
  code : (or/c #f string?)
  tags : (listof string?)
  client-id : (or/c #f exact-nonnegative-integer?)
struct
(struct client (id name)
    #:transparent)
  id : exact-nonnegative-integer?
  name : string?
struct
(struct allocation (start-date end-date rate)
    #:transparent)
  start-date : date?
  end-date : date?
  rate : exact-nonnegative-integer?
struct
(struct assignment (person-id
                    project-id
                    start-date
                    end-date
                    allocation)
    #:transparent)
  person-id : exact-nonnegative-integer?
  project-id : exact-nonnegative-integer?
  start-date : date?
  end-date : date?
  allocation : exact-nonnegative-integer?
procedure
(allocation<? alloc1 alloc2) -> boolean?
  alloc1 : allocation?
  alloc2 : allocation?
procedure
(get-the-schedule) -> schedule?
procedure
(connect host account-id access-token) -> connection?
  host : string?
  account-id : string?
  access-token : string?
procedure
(get-the-forecast-schedule start-date     
                           end-date)  -> schedule?
  start-date : date?
  end-date : date?
procedure
(get-team conn) -> (listof person?)
  conn : connection?
procedure
(get-projects conn) -> (listof project?)
  conn : connection?
procedure
(get-clients conn) -> (listof person?)
  conn : connection?
procedure
(get-assignments conn) -> (listof person?)
  conn : connection?
procedure
(connect host account-id access-token) -> connection?
  host : string?
  account-id : string?
  access-token : string?
procedure
(get-people conn) -> jsexpr?
  conn : connection?
procedure
(get-placeholders conn) -> jsexpr?
  conn : connection?
procedure
(get-projects conn) -> jsexpr?
  conn : connection?
procedure
(get-clients conn) -> jsexpr?
  conn : connection?
procedure
(get-assignments conn) -> jsexpr?
  conn : connection?
