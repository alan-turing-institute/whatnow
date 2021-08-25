3648
((3) 0 () 12 ((q lib "whatnow/db.rkt") (q 1263 . 6) (q lib "whatnow/schedule.rkt") (q 1147 . 5) (q lib "whatnow/config.rkt") (q 60 . 5) (q lib "whatnow/api/forecast-json.rkt") (q 1968 . 7) (q 334 . 16) (q 1429 . 12) (q 820 . 9) (q lib "whatnow/forecast.rkt")) () (h ! (equal) ((c def c (c (? . 0) q allocation-start-date)) c (? . 1)) ((c def c (c (? . 0) q struct:allocation)) c (? . 1)) ((c def c (c (? . 4) q server-account?)) c (? . 5)) ((c def c (c (? . 2) q schedule?)) c (? . 7)) ((c def c (c (? . 0) q client?)) c (? . 3)) ((c def c (c (? . 2) q get-the-schedule)) q (1924 . 2)) ((c def c (c (? . 0) q client-name)) c (? . 3)) ((c def c (c (? . 6) q get-clients)) q (2971 . 3)) ((c def c (c (? . 0) q assignment?)) c (? . 9)) ((c def c (c (? . 4) q server-account-id)) c (? . 5)) ((c def c (c (? . 0) q person-roles)) c (? . 8)) ((c def c (c (? . 0) q allocation-end-date)) c (? . 1)) ((c def c (c (? . 6) q get-projects)) q (2902 . 3)) ((c def c (c (? . 2) q schedule-people)) c (? . 7)) ((c def c (c (? . 11) q get-clients)) q (2483 . 3)) ((c def c (c (? . 0) q person-last-name)) c (? . 8)) ((c def c (c (? . 0) q allocation<?)) q (1815 . 4)) ((c def c (c (? . 0) q person?)) c (? . 8)) ((c def c (c (? . 0) q person)) c (? . 8)) ((c def c (c (? . 4) q config-get-accounts)) q (167 . 4)) ((c def c (c (? . 0) q client)) c (? . 3)) ((c def c (c (? . 6) q connect)) q (2643 . 4)) ((c def c (c (? . 0) q struct:project)) c (? . 10)) ((c def c (c (? . 0) q assignment-start-date)) c (? . 9)) ((c def c (c (? . 0) q project-name)) c (? . 10)) ((c def c (c (? . 0) q allocation?)) c (? . 1)) ((c def c (c (? . 0) q person-id)) c (? . 8)) ((c def c (c (? . 2) q schedule-programmes)) c (? . 7)) ((c def c (c (? . 2) q schedule-assignments)) c (? . 7)) ((c def c (c (? . 0) q struct:person)) c (? . 8)) ((c def c (c (? . 11) q connect)) q (2209 . 4)) ((c def c (c (? . 0) q project)) c (? . 10)) ((c def c (c (? . 4) q struct:server-account)) c (? . 5)) ((c def c (c (? . 0) q assignment)) c (? . 9)) ((c def c (c (? . 0) q person-first-name)) c (? . 8)) ((c def c (c (? . 2) q struct:schedule)) c (? . 7)) ((c def c (c (? . 0) q project-code)) c (? . 10)) ((c def c (c (? . 0) q project-client-id)) c (? . 10)) ((q def ((lib "whatnow/api/local-config.rkt") FORECAST-SERVER)) q (0 . 2)) ((c def c (c (? . 0) q project-id)) c (? . 10)) ((c def c (c (? . 0) q assignment-end-date)) c (? . 9)) ((c def c (c (? . 0) q allocation)) c (? . 1)) ((c def c (c (? . 0) q client-id)) c (? . 3)) ((c def c (c (? . 0) q assignment-project-id)) c (? . 9)) ((c def c (c (? . 0) q person-email)) c (? . 8)) ((c def c (c (? . 11) q get-assignments)) q (2561 . 3)) ((c def c (c (? . 0) q project-tags)) c (? . 10)) ((c def c (c (? . 6) q get-people)) q (2762 . 3)) ((c def c (c (? . 6) q get-placeholders)) q (2829 . 3)) ((c def c (c (? . 0) q project?)) c (? . 10)) ((c def c (c (? . 0) q allocation-rate)) c (? . 1)) ((c def c (c (? . 2) q schedule-projects)) c (? . 7)) ((c def c (c (? . 0) q project-harvest-id)) c (? . 10)) ((c def c (c (? . 0) q struct:client)) c (? . 3)) ((c def c (c (? . 0) q assignment-allocation)) c (? . 9)) ((c def c (c (? . 11) q get-team)) q (2328 . 3)) ((c def c (c (? . 0) q assignment-person-id)) c (? . 9)) ((c def c (c (? . 4) q server-account-token)) c (? . 5)) ((c def c (c (? . 11) q get-projects)) q (2403 . 3)) ((c def c (c (? . 6) q get-assignments)) q (3039 . 3)) ((c def c (c (? . 0) q struct:assignment)) c (? . 9)) ((c def c (c (? . 0) q person-login?)) c (? . 8)) ((c def c (c (? . 4) q server-account)) c (? . 5)) ((c def c (c (? . 0) q person-harvest-id)) c (? . 8)) ((c def c (c (? . 2) q schedule)) c (? . 7))))
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
struct
(struct schedule (people projects programmes assignments)
    #:transparent)
  people : (listof person?)
  projects : (listof project?)
  programmes : (listof programme?)
  assignments : (listof assignment?)
procedure
(connect account-id access-token) -> connection?
  account-id : string?
  access-token : string?
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
(connect account-id access-token) -> connection?
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
