# RunnerJob

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**uuid** | **UUID** |  | [optional] 
**type** | [**RunnerJobType**](RunnerJobType.md) |  | [optional] 
**state** | [**RunnerJobStateConstant**](RunnerJobStateConstant.md) |  | [optional] 
**payload** | [**RunnerJobPayload**](RunnerJobPayload.md) |  | [optional] 
**failures** | **Int** | Number of times a remote runner failed to process this job. After too many failures, the job in \&quot;error\&quot; state | [optional] 
**error** | **String** | Error message if the job is errored | [optional] 
**progress** | **Int** | Percentage progress | [optional] 
**priority** | **Int** | Job priority (less has more priority) | [optional] 
**updatedAt** | **Date** |  | [optional] 
**createdAt** | **Date** |  | [optional] 
**startedAt** | **Date** |  | [optional] 
**finishedAt** | **Date** |  | [optional] 
**parent** | [**RunnerJobParent**](RunnerJobParent.md) |  | [optional] 
**runner** | [**RunnerJobRunner**](RunnerJobRunner.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


