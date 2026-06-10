Class {
	#name : 'AllocationSitesPretenurer',
	#superclass : 'Object',
	#instVars : [
		'transformedCallSites',
		'pretenuredCompiledMethods',
		'methodProtocol',
		'transformedSenders',
		'callSiteTransformers'
	],
	#category : 'SendersChainTransformer-Code-Rewriter',
	#package : 'SendersChainTransformer',
	#tag : 'Code-Rewriter'
}

{ #category : 'api' }
AllocationSitesPretenurer >> backupMethodsWithOffset: aListOfMethods [

   callSiteTransformers do: [ :codeTransformer |
		codeTransformer backupMethods: (aListOfMethods collect: [ :m | m method method ]) ]
]

{ #category : 'api' }
AllocationSitesPretenurer >> compilePretenuredPathsFrom: toPretenurePaths [

   callSiteTransformers := OrderedCollection new.

   toPretenurePaths do: [ :stack |
         | transformer initialCaller senders |
         transformer := CallSiteTransformer new.
         initialCaller := stack last.
         senders := stack allButLast.
         [
            transformer transformCallSite: initialCaller senders: senders.
            callSiteTransformers add: transformer
			]
            on: SCTransformationException
            do: [ :error | self logCompilationError: error senders: senders initialCaller: initialCaller ] ].

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
   methodProtocol := 'automatically-generated'
]

{ #category : 'api' }
AllocationSitesPretenurer >> installPretenuredMethods [

    transformedSenders do: [ :aCompiledMethod |
            ('Installing method ' , aCompiledMethod name) traceCr.
            callSiteTransformers anyOne installPretenuredMethod: aCompiledMethod ].
    transformedCallSites do: [ :aCompiledMethod |
            ('Installing method ' , aCompiledMethod name) traceCr.
            callSiteTransformers anyOne installMethod: aCompiledMethod ]
]

{ #category : 'api' }
AllocationSitesPretenurer >> logCompilationError: error senders: senders initialCaller: initialCaller [

   | senderNames |
   senderNames := String streamContents: [ :stream |
		senders do: [ :sender |
			stream
			nextPutAll: sender selector;
			space ] ].
   ('Error transforming: ' , initialCaller selector, ' with senders: ' , senderNames , ' - ' , error description) traceCr
]

{ #category : 'internals' }
AllocationSitesPretenurer >> mergeTransformations [
    "It can happen that the same method was modified twice because it appeared in the senders stack twice with different bytecode offsets"

    transformedCallSites := callSiteTransformers collect: #transformedCallSite thenReject: #isNil.
    transformedSenders := (callSiteTransformers flatCollect: #transformedSenders) reject: #isNil.
	
    transformedCallSites := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedCallSites.
    transformedSenders := CodeTransformationsMerger new mergeTransformedCompiledMethods: transformedSenders
]

{ #category : 'api - accessing' }
AllocationSitesPretenurer >> methodProtocol: aString [

	methodProtocol := aString
]

{ #category : 'api' }
AllocationSitesPretenurer >> restoreOriginalState [

   callSiteTransformers do: #restoreOriginalState
]

{ #category : 'api' }
AllocationSitesPretenurer >> transformedCallSites [

	^ transformedCallSites
]

{ #category : 'api' }
AllocationSitesPretenurer >> transformedSenders [

	^ transformedSenders
]
