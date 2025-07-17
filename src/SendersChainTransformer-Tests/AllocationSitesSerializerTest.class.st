"
An AllocationSitesExperimentTest is a test class for testing the behavior of AllocationSitesExperiment
"
Class {
	#name : 'AllocationSitesSerializerTest',
	#superclass : 'TestCase',
	#instVars : [
		'senders',
		'fileName'
	],
	#category : 'SendersChainTransformer-Tests-Experiment',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Experiment'
}

{ #category : 'running' }
AllocationSitesSerializerTest >> setUp [

    super setUp.

	 fileName := (Random new nextInteger: 100000) asString , '.json'.
    senders := {
			{
				(MethodWithOffset method: OrderedCollection >> #add: offset: 35).
				(MethodWithOffset method: OrderedCollection >> #addLast: offset: 47).
				(MethodWithOffset method: OrderedCollection >> #makeRoomAtLast offset: 83).
				(MethodWithOffset method: OrderedCollection >> #growAtLast offset: 74) }.
			{
				(MethodWithOffset method: Association class >> #key:value: offset: 42) } }
]

{ #category : 'running' }
AllocationSitesSerializerTest >> tearDown [

    fileName asFileReference delete.

    super tearDown
]

{ #category : 'tests' }
AllocationSitesSerializerTest >> testSerializeAndDeserialize [

    | deserializedArray writeStream |
    "Serialize"
    writeStream := fileName asFileReference createFile writeStream.
    AllocationSitesSerializer new serialize: senders on: writeStream.

    "Deserialize"
    deserializedArray := AllocationSitesSerializer new deserialize: fileName asFileReference contents.
    deserializedArray doWithIndex: [ :array :i |
            array doWithIndex: [ :methodWithOffset :j |
                    self assert: methodWithOffset method ast equals: ((senders at: i) at: j) method ast.
                    self assert: methodWithOffset offset equals: ((senders at: i) at: j) offset ] ]
]
