
$ ./create.sh
$ kubectl describe svc hello-svc
Name:                     hello-svc
Namespace:                default
Labels:                   app=hello-world
Annotations:              <none>
Selector:                 app=hello-world
Type:                     NodePort
IP:                       10.101.218.96       <----- IP to use
Port:                     <unset>  8080/TCP   <----- Port to use
TargetPort:               8080/TCP
NodePort:                 <unset>  30001/TCP
Endpoints:                <none>
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>

$ curl http://10.101.218.96:8080
<html>
   <head>
      <title>Pluralsight Rocks</title>
      <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
   </head>
   <body>
      <div class="container">
         <div class="jumbotron">
            <h1>Yo Pluralsighters!!!</h1>
            <p>Click the button below to head over to my podcast...</p>
            <p> <a href="http://intechwetrustpodcast.com" class="btn btn-primary">Podcast</a></p>
            <p></p>
         </div>
      </div>
   </body>
</html>
