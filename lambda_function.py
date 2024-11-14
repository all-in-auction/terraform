# lambda_function.py
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    action = event.get("action")
    instance_ids = [] #ec2 instance id
    
    if action == "stop":
        ec2.stop_instances(InstanceIds=instance_ids)
        return {"status": "stopped", "instances": instance_ids}
    
    elif action == "start":
        ec2.start_instances(InstanceIds=instance_ids)
        return {"status": "started", "instances": instance_ids}
    
    else:
        return {"status": "no action specified"}
