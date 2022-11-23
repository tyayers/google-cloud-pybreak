import os
import web
import json
import datetime
from urllib import parse

import googleapiclient.discovery
from google.protobuf import duration_pb2, timestamp_pb2
from google.cloud import logging
from google.cloud import tasks_v2

urls = (
    '/breakglass', 'breakglass'
)
app = web.application(urls, globals())

logging_client = logging.Client()
logger = logging_client.logger("breakglass-log")
tasks_client = tasks_v2.CloudTasksClient()

serviceAccountEmail = os.environ.get("SERVICE_ACCOUNT")
elevatedRole = os.environ.get("ROLE")
if not elevatedRole:
    elevatedRole = "roles/owner"

location = os.environ.get("LOCATION")

class breakglass:
  """Class for managing the elevated rights for users."""

  def GET(self):
    """Gets the current policy, returns OK to signify that access to IAM policies is working (test call)."""

    project = web.input().project

    service = googleapiclient.discovery.build(
      "cloudresourcemanager", "v1"
    )
    policy = get_policy(service, project) 

    web.header('Content-Type', 'application/json')
    return json.dumps({"result": "OK"})

  def POST(self):
    """Elevates rights for a given user and project, returns 200 OK if successful."""

    project = web.input().project
    user=web.input().user

    logger.log_text("Starting request to BREAK GLASS and elevate {user} for project {project}".format(user=user, project=project))

    service = googleapiclient.discovery.build(
        "cloudresourcemanager", "v1"
    )

    policy = get_policy(service, project)
    modify_policy_add_member(service, project, policy, elevatedRole, user)

    schedule_remove_elevation(project, location, user)

    logger.log_text("Successfully completed request to BREAK GLASS and elevate {user} for project {project}".format(user=user, project=project))

    web.header('Content-Type', 'application/json')
    return json.dumps({"result": "OK"})

  def DELETE(self):
    """Removes the elevated rights for a given user and project, returns 200 OK if successful."""

    project = web.input().project
    user=web.input().user

    logger.log_text("Starting request to RESET GLASS and remove elevated rights of {user} for project {project}".format(user=user, project=project))

    service = googleapiclient.discovery.build(
        "cloudresourcemanager", "v1"
    )

    policy = get_policy(service, project)
    
    modify_policy_remove_member(service, project, policy, elevatedRole, user)

    logger.log_text("Finished request to RESET GLASS and remove elevated rights of {user} for project {project}".format(user=user, project=project))

    web.header('Content-Type', 'application/json')
    return json.dumps({"result": "OK"})

def schedule_remove_elevation(project_id, location_id, user):
    """Creates the Cloud Scheduler job to remove elevation"""

    # Construct the fully qualified queue name.
    parent = tasks_client.queue_path(project_id, location_id, "breakglass-reset-queue")
    remove_previous_user_tasks(project_id, location_id, user)

    # Construct the request body.
    task = {
        "http_request": {  # Specify the type of request.
            "http_method": tasks_v2.HttpMethod.DELETE,
            "url": web.ctx.home.replace("http://", "https://") + "/breakglass?project={project_id}&user={user}".format(project_id=project_id, user=user),  # The full url path that the task will be sent to.
            "oidc_token": {
                "service_account_email": serviceAccountEmail,
                "audience": web.ctx.home.replace("http://", "https://"),
            },
        }
    }

    # d = datetime.datetime.utcnow() + datetime.timedelta(hours=10)
    d = datetime.datetime.utcnow() + datetime.timedelta(minutes=10)
 
    # Create Timestamp protobuf.
    timestamp = timestamp_pb2.Timestamp()
    timestamp.FromDatetime(d)

    # Add the timestamp to the tasks.
    task["schedule_time"] = timestamp

    response = tasks_client.create_task(request={"parent": parent, "task": task})

def remove_previous_user_tasks(project_id, location_id, user):
    """Deletes any previously created tasks to remove elevation earlier"""
    
    parent = tasks_client.queue_path(project_id, location_id, "breakglass-reset-queue")
    response = tasks_client.list_tasks(request={"parent": parent})

    for task in response:
        if parse.parse_qs(parse.urlparse(task.http_request.url).query)['user'][0] == user:
            del_response = tasks_client.delete_task(name=task.name)

def get_policy(service, project_id, version=1):
    """Gets the current policy for a project."""

    policy = (
        service.projects()
        .getIamPolicy(
            resource=project_id,
            body={"options": {"requestedPolicyVersion": version}},
        )
        .execute()
    )

    return policy

def modify_policy_add_member(service, project_id, policy, role, member):
    """Adds a new member to a role binding."""

    binding = next(b for b in policy["bindings"] if b["role"] == role)
    binding["members"].append(member)

    policy = (
        service.projects()
        .setIamPolicy(resource=project_id, body={"policy": policy})
        .execute()
    )

    return policy

def modify_policy_remove_member(service, project_id, policy, role, member):
    """Removes a  member from a role binding."""

    binding = next(b for b in policy["bindings"] if b["role"] == role)
    if "members" in binding and member in binding["members"]:
        binding["members"].remove(member)

    policy = (
        service.projects()
        .setIamPolicy(resource=project_id, body={"policy": policy})
        .execute()
    )

    return policy

if __name__ == "__main__":
    app.run()
