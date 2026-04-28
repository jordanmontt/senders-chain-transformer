Class {
	#name : 'AllocationSitesPretenurer',
	#superclass : 'Object',
	#instVars : [
		'transformedCallSites',
		'pretenuredCompiledMethods',
		'methodProtocol',
		'transformedSenders',
		'callSiteTransformer'
	],
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
}

{ #category : 'api' }
AllocationSitesPretenurer >> backupMethodsWithOffset: aListOfMethods [

	callSiteTransformer backupMethods: (aListOfMethods collect: [ :m | m method method ])
]

{ #category : 'api' }
AllocationSitesPretenurer >> compilePretenuredPathsFrom: toPretenurePaths [

    | initialCallers senders |
    initialCallers := toPretenurePaths collect: [ :stack |  stack last ].
    senders := toPretenurePaths flatCollect: [ :stack | stack allButLast ].

    callSiteTransformer transformCallSites: initialCallers senders: senders.
    self mergeTransformations
]

{ #category : 'api' }
AllocationSitesPretenurer >> exportPretenuredMethods: writeStream [

	"file name must end in .json"
	self fetchPretenuredCompiledMethods.

	CompiledMethodToSourceCodeSerializer new
		serialize: pretenuredCompiledMethods
		on: writeStream
]

{ #category : 'api' }
AllocationSitesPretenurer >> fetchPretenuredCompiledMethods [

	pretenuredCompiledMethods := transformedSenders , transformedCallSites.
	^ pretenuredCompiledMethods
]

{ #category : 'initialization' }
AllocationSitesPretenurer >> initialize [

	super initialize.
	callSiteTransformer := CallSiteTransformer new.
	methodProtocol := 'automatically-generated'
]

{ #category : 'api' }
AllocationSitesPretenurer >> installPretenuredMethods [

    transformedSenders do: [ :aCompiledMethod |
            ('Installing method ' , aCompiledMethod name) traceCr.
            callSiteTransformer installMethod: aCompiledMethod ].
    transformedCallSites do: [ :aCompiledMethod |
            ('Installing method ' , aCompiledMethod name) traceCr.
            callSiteTransformer installMethod: aCompiledMethod ]
]

{ #category : 'internals' }
AllocationSitesPretenurer >> mergeTransformations [
    "It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"

    transformedCallSites := callSiteTransformer transformedCallSites reject: #isNil.
    transformedSenders := callSiteTransformer transformedSenders reject: #isNil.
	
    transformedCallSites := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedCallSites.
    transformedSenders := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedSenders
]

{ #category : 'api - accessing' }
AllocationSitesPretenurer >> methodProtocol: aString [

	methodProtocol := aString
]

{ #category : 'api' }
AllocationSitesPretenurer >> restoreOriginalState [

	callSiteTransformer restoreOriginalState
]
