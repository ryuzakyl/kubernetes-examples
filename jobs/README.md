# create a Job which prints "Hello World"
kubectl create job hello --image=busybox -- echo "Hello World"

# create a CronJob that prints "Hello World" every minute
kubectl create cronjob hello --image=busybox   --schedule="*/1 * * * *" -- echo "Hello World"