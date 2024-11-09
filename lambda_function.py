# lambda_function.py
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    action = event.get("action")
    instance_ids = ["i-0896d591eec603007", "i-0d400e4c490f86acd", "i-0da5732e6f8b8d497"] #redis, mysql, rabbitmq
    
    if action == "stop":
        ec2.stop_instances(InstanceIds=instance_ids)
        return {"status": "stopped", "instances": instance_ids}
    
    elif action == "start":
        ec2.start_instances(InstanceIds=instance_ids)
        return {"status": "started", "instances": instance_ids}
    
    else:
        return {"status": "no action specified"}
