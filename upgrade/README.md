# Zero down time Upgrade

With an application given the diagram below, what would be some methods for updating this

application with zero down time?  Assume that the instance runs an nginx webserver.


![Upgrade situation](/upgrade/upgrade.png)

## Response

Two common upgrade practices come to mind when thinking of this. The first would be blue/green upgrades and the second would be canary upgrades.

Depending on the requirements of the application we could potentially upgrade with either.

# Blue/Green

If the project needs every instance to be upgraded at the same time then blue green would be the way to go. 
For this scenario I am assuming the ELB sits behind a DNS entry or vip. We could potentially create an entirely new green ELB that routes to all new green instances of the application. We could then just switch the DNS or the vip to point to the completely new ELB which will then route to the new instances thus completing the switch to green. For the rest of my explanation I will assume the ELB just has a DNS entry in front of it.  After some testing the blue ELB and instances could then be deleted. The reason we would not delete them immediately after the switch is so that we have the capability to rollback should issues be found with the green. Rollback would be another simple switch of the IP that the DNS A record is pointing to.

# Canary
If the application is capable of having just a subset of instances upgrade while still functioning with some instances running the old version then a canary upgrade style would be the favored approach. For the rest of this explanation I will assume there are just 3 instances to be upgrades for the sake of simplicity. To perform a canary upgrade in this scenario we would just upgrade 1 instance at first. With this pattern we are allowing a subset of traffic that is routing to the newly upgrades instance to give us confidence and comfort that the application is working as expected. Should the application report issues, fail health checks or just overall not work we can simply roll back the one instance to the previous version. Should the application work as expected we could then upgrade another instance to the new version. With each new version (canary) we put out there we would gain more and more confidence in the new version of the application. Over time all instances would be upgraded. Netflix utilizes a pattern called the dark canary upgrade. The dark canary is the first instance upgraded. This "dark" instance is a production instance but can only be accessed by the internal company teams. This dark canary is rolled out first and then manually tested in the production environment by the deployment teams. This dark canary gives them their first vote of confidence. Should it work as expected then more canaries will be upgrades allowing more and more traffic to be routed to the newly upgraded instances.

For more technical information as to how the instances would be upgraded and switched in the LB I am unfortunately not very familiar with AWS ELB which is what I am assuming this project to be using. I have more experience with haproxy. That being said I imagine there is some way for the routes to be determined via some sort of service discovery tool like etcd, zookeeper or zuul. If the LB's routes are determined dynamically via service discovery then we could simply upgrade our canaries by introducing changes in the values held by the service discovery.

Below is a small text example that attempts to clarify what I am explaining about the first canary's service discovery value being updated to point to the new version of an instance.

```
app1 = instance1.application.com/v1 -> app1 = instance1.application.com/v2 //first canary
app2 = instance2.application.com/v1 -> app2 = instance2.application.com/v1
app3 = instance3.application.com/v1 -> app3 = instance3.application.com/v1
```

## Uptime and monitoring

Given the same application from question 3, how do you know the application is working correctly?

 What monitoring or metrics would you put in place if this was a production website?

## Response 

The dark canary approach above gives us the ability to test internally. After each canaries is released more and more users will be using the upgrade.

In the blue/green scenario we are not able to get that sort of small start and slow building of confidence. Instead there we would have to rely much more on automated testing earlier in the software development life-cycle. After it is live in production we would effectively be testing along side our user base which I find to be a less optimal situation that canary upgrade.

Monitoring and metrics will give us confidence that the application is working as expected. For monitoring I am most familiar with sensu. These sensu checks can perform many customized checks on polling intervals as report issues should the checks not pass. I would definitely use sensu on a production website along with health check endpoints for sensu to query. The health check endpoints internally could verify many different points of failure such as database connection or the ability to talk to other micro services our application depends on. Should the health check return a failure to the sensu check alerts can be sent to the team to diagnose quickly.

As for metrics I would imagine AWS has quite the metric tooling behind it. I have used the TICK stack which is an open source set of tools for metrics. Telgraf, Influx DB, Grafana, Kapacitor. Telegraf would be installed and configured on each instance to report its metrics to be stored in the influxDB. Grafana then queries the DB to provide many different graphical representations that can be used by humans. Kapacitor an be configured to provide alerting and execute actions based on anamolies. Another great product I have tried is Datadog. This is a paid tool only with no open source offerings. It is deployed on to each instance and has support from a wide array of deployment configuration technologies. I believe it is also supported for monitoring docker containers now. I have deployed this previously with chef and found it to be relatively easy to set up. 

## Time

I spent approximately 1 hour on this question. 