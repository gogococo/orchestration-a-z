# SockShop Demo

This is an updated version of the [Sock Shop demo](https://microservices-demo.github.io/)
for Nomad.

## Running the demo

This demo comes with a Vagrant box that can be used to quickly get started.
It's a 4 cores, 8GB box, so make sure you have enough memory available in your
host.

Start by bringing the machine up and SSHing into it:

```shellsession
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Checking if box 'ubuntu/bionic64' version '20200518.1.0' is up to date...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
...
$ vagrant ssh
```

From the box, you can start all the jobs with the commands:

```shellsession
vagrant@ubuntu-bionic:~$ cd ./sockshop/jobs/
vagrant@ubuntu-bionic:~/sockshop/jobs$ make -j 5
nomad run carts.nomad
nomad run catalogue.nomad
nomad run frontend.nomad
...
```

After a few minutes you should be able to access the application from
[http://localhost:8080](http://localhost:8080).

### Load test

You can run the load test as a parameterized Nomad job.

Load the paramaterized job into the nomad cluster.

```shellsession
vagrant@ubuntu-bionic:~/sockshop/jobs$ nomad run loadtest.nomad
Job registration successful
```

You can then run instances of the load tester using the `nomad job dispatch`
command. You can control the load test by passing in arguments using the
`-meta` flag.

```shellsession
vagrant@ubuntu-bionic:~/sockshop/jobs$ nomad job dispatch -meta delay=30 -meta clients=2 -meta requests=100 sockshop-loadtest
Dispatched Job ID = sockshop-loadtest/dispatch-1597260903-9967334c
Evaluation ID     = 1cf02ab4

==> Monitoring evaluation "1cf02ab4"
    Evaluation triggered by job "sockshop-loadtest/dispatch-1597260903-9967334c"
    Allocation "be64f662" created: node "ee61a687", group "load"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "1cf02ab4" finished with status "complete"
```

Test results can be seen in the `stderr` output of the allocation.

```shellsession
vagrant@ubuntu-bionic:~/sockshop/jobs$ nomad alloc logs -f -stderr <ALLOC ID> gen
[2020-08-12 19:35:38,661] f399912546dc/INFO/locust.main: Starting Locust 0.7.5
[2020-08-12 19:35:38,661] f399912546dc/INFO/locust.runners: Hatching and swarming 5 clients at the rate 5 clients/s...
[2020-08-12 19:35:39,666] f399912546dc/INFO/locust.runners: All locusts hatched: Web: 5
[2020-08-12 19:35:39,666] f399912546dc/INFO/locust.runners: Resetting stats

[2020-08-12 19:35:52,638] f399912546dc/INFO/locust.runners: All locusts dead

[2020-08-12 19:35:52,638] f399912546dc/INFO/locust.main: Shutting down (exit code 1), bye.
 Name                                                          # reqs      # fails     Avg     Min     Max  |  Median   req/s
--------------------------------------------------------------------------------------------------------------------------------------------
 GET /                                                            112     0(0.00%)      52      45      72  |      51    8.50
 GET /basket.html                                                 110     0(0.00%)      50      44      82  |      49    8.50
 DELETE /cart                                                     111     0(0.00%)      25      14      50  |      25    8.50
 POST /cart                                                       110     0(0.00%)      45      26      77  |      44    8.50
 GET /catalogue                                                   111     0(0.00%)      66      50     103  |      64    8.50
 GET /category.html                                               112     0(0.00%)      52      45      67  |      51    8.60
 GET /detail.html?id=03fef6ac-1896-4ce8-bd69-b798f85c6e0b          15     0(0.00%)      53      45      60  |      54    1.30
 GET /detail.html?id=3395a43e-2d88-40de-b95f-e00e1502085b          13     0(0.00%)      52      47      63  |      52    1.10
 GET /detail.html?id=510a0d7e-8e83-4193-b483-e27e09ddc34d          13     0(0.00%)      53      47      66  |      53    0.90
 GET /detail.html?id=808a2de1-1aaa-4c25-a9b9-6612e8f29a38          12     0(0.00%)      52      49      57  |      51    1.00
 GET /detail.html?id=819e1fbf-8b7e-4f6d-811f-693534916a8b           8     0(0.00%)      52      50      63  |      50    0.20
 GET /detail.html?id=837ab141-399e-4c1f-9abc-bace40296bac          12     0(0.00%)      53      48      64  |      52    0.90
 GET /detail.html?id=a0a4f044-b040-410d-8ead-4de0446aec7e          12     0(0.00%)      52      45      68  |      51    1.00
 GET /detail.html?id=d3588630-ad8e-49df-bbd7-3167f7efb246          17     0(0.00%)      51      47      57  |      52    1.50
 GET /detail.html?id=zzz4f044-b040-410d-8ead-4de0446aec7e           9     0(0.00%)      50      47      57  |      48    0.80
 GET /login                                                       111     0(0.00%)      91      64     127  |      90    8.60
 POST /orders                                                     101    11(9.82%)     139      98     199  |     140    7.60
--------------------------------------------------------------------------------------------------------------------------------------------
 Total                                                            989    11(1.11%)                                      76.00

Percentage of the requests completed within given times
 Name                                                           # reqs    50%    66%    75%    80%    90%    95%    98%    99%   100%
--------------------------------------------------------------------------------------------------------------------------------------------
 GET /                                                             112     51     53     55     56     58     60     64     68     72
 GET /basket.html                                                  110     49     51     52     53     56     62     73     76     82
 DELETE /cart                                                      111     25     28     30     32     34     36     40     47     50
 POST /cart                                                        110     45     49     53     55     62     63     70     73     77
 GET /catalogue                                                    111     64     68     71     72     78     80     89     92    103
 GET /category.html                                                112     51     53     55     56     61     64     64     64     67
 GET /detail.html?id=03fef6ac-1896-4ce8-bd69-b798f85c6e0b           15     54     55     58     58     59     60     60     60     60
 GET /detail.html?id=3395a43e-2d88-40de-b95f-e00e1502085b           13     52     53     53     55     58     63     63     63     63
 GET /detail.html?id=510a0d7e-8e83-4193-b483-e27e09ddc34d           13     53     54     55     57     64     66     66     66     66
 GET /detail.html?id=808a2de1-1aaa-4c25-a9b9-6612e8f29a38           12     52     52     55     55     56     57     57     57     57
 GET /detail.html?id=819e1fbf-8b7e-4f6d-811f-693534916a8b            8     51     52     55     55     63     63     63     63     63
 GET /detail.html?id=837ab141-399e-4c1f-9abc-bace40296bac           12     53     54     56     56     57     64     64     64     64
 GET /detail.html?id=a0a4f044-b040-410d-8ead-4de0446aec7e           12     51     52     55     55     68     68     68     68     68
 GET /detail.html?id=d3588630-ad8e-49df-bbd7-3167f7efb246           17     52     53     54     54     55     57     57     57     57
 GET /detail.html?id=zzz4f044-b040-410d-8ead-4de0446aec7e            9     48     52     53     53     57     57     57     57     57
 GET /login                                                        111     90     95    100    100    110    110    120    130    127
 POST /orders                                                      101    140    150    160    160    170    180    190    200    199
--------------------------------------------------------------------------------------------------------------------------------------------

Error report
 # occurences       Error
--------------------------------------------------------------------------------------------------------------------------------------------
 12                 POST /orders: "HTTPError(u'406 Client Error: Not Acceptable for url: http://sockshop-edgerouter.service.consul/orders',)"
--------------------------------------------------------------------------------------------------------------------------------------------
```

#### Load test as Docker container

Alternatively, you can run the load test directly in a container with the
command:

```shellsession
vagrant@ubuntu-bionic:~/sockshop/jobs$ docker run --net=host weaveworksdemos/load-test -h localhost -r 150 -c 5
Locust file: /config/locustfile.py
Will run /config/locustfile.py against localhost. Spawning 5 clients and 150 total requests.
[2020-08-11 17:56:41,201] ubuntu-bionic/INFO/locust.main: Starting Locust 0.7.5
[2020-08-11 17:56:41,201] ubuntu-bionic/INFO/locust.runners: Hatching and swarming 5 clients at the rate 5 clients/s...
^C^[[A[2020-08-11 17:56:42,205] ubuntu-bionic/INFO/locust.runners: All locusts hatched: Web: 5
[2020-08-11 17:56:42,205] ubuntu-bionic/INFO/locust.runners: Resetting stats

[2020-08-11 17:56:44,617] ubuntu-bionic/INFO/locust.runners: All locusts dead

[2020-08-11 17:56:44,618] ubuntu-bionic/INFO/locust.main: Shutting down (exit code 0), bye.
...
done
```

You can customize the `-r` and `-c` parameters to change the number of
requests and clients to use.

### Stopping the demo

```shellsession
vagrant@ubuntu-bionic:~/sockshop/jobs$ make stop-all -j 5
nomad stop -purge sockshop-carts
nomad stop -purge sockshop-catalogue
nomad stop -purge sockshop-frontend
nomad stop -purge sockshop-infra
...
vagrant@ubuntu-bionic:~/sockshop/jobs$ exit
...
$ vagrant halt
```

### TODO

* [ ] Monitoring
* [ ] Autoscaling
* [ ] Volumes
* [ ] Vault
* [ ] Health checks
* [ ] ACL
* [ ] Log aggregation
* [ ] Multiple task drivers
* [ ] Cloud deployments
* [x] Load test as dispatch batch job
* [ ] Use Levant
* [ ] Consul Intentions
