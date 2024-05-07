import json
import boto3

def lambda_handler(event, context):
    print(event)
    
    launch_template_id = event['LaunchTemplateId']
    owner = event['Owner']
    image_prefix = event['ImagePrefix']
    
    ec2 = boto3.client("ec2")
    filters = [
      { "Name" : "name", "Values" : [image_prefix] },
      { "Name" : "virtualization-type", "Values" : ["hvm"] },
      { "Name" : "state", "Values" : ["available"] }
    ]
    images = ec2.describe_images(Owners=[owner], Filters=filters)
    images = sorted(images['Images'], key=lambda x : x['CreationDate'])
    images.reverse()
    print(images[0]['ImageId'])
    response = ec2.describe_launch_templates(
        LaunchTemplateIds=[launch_template_id]
        )
    latest_version_lt = response['LaunchTemplates'][0]['LatestVersionNumber']
    print(latest_version_lt)
    lt = ec2.create_launch_template_version(
        LaunchTemplateData={
            'ImageId': images[0]['ImageId']
            },
        LaunchTemplateId=launch_template_id,
        SourceVersion=str(latest_version_lt)
    )
    return {'LaunchTemplateVersion': lt['LaunchTemplateVersion']['VersionNumber']}