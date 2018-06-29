#! groovy

def isMaster = false
def tests = []

def unitTests(testName) {
	return {
		// macOS VMs must run on mac
		def labels = 'osx'
		// Ubuntu VMs can run on mac or linux
		// but let's peg to linux so the mac/win VMs get macs
		if (testName.contains('-ubuntu')) {
			labels = 'linux'
		} else if (testName.contains('-windows')) {
			// Windows VMs work on osx nodes, or ginsubuntu and ginsubuntu02 are beefy enough to run it
			// TODO: Try the new ubuntu nodes from ECD?
			labels = '(osx || ginsubuntu || ginsubuntu02)'
		}
		node("chefdk && ${labels} && axway-internal") { // internal to reach itamae chef server
			unstash 'sources'
			sh 'rm -rf .kitchen/'
			sh 'rm -rf .vagrant/'
			sh 'rm -rf *inspec.xml'
			// Spit out the versions of the tools used here.
			sh 'kitchen -v'
			sh 'berks version'
			sh 'vagrant version'
			// FIXME: Do a berks install once in earlier stage, then stash?
			sh 'berks install' // installs all the cookbooks to local cache, using Berksfile.lock
			try {
				// withEnv(['KITCHEN_YAML=.kitchen.ci.yml']) {
					sh "kitchen diagnose ${testName}"
					sh "kitchen test ${testName}"
				// }
			}
			catch (e) {
				archiveArtifacts '.kitchen/logs/*.log'
				throw e
			}
			finally {
				sh 'kitchen destroy all'
				junit '*-inspec.xml' // FIXME: test name removes periods, but filename doesn't...
			}
			// Now just wipe the junit reports so next run won't have any there already (but we could re-use the cookbook installs)
			sh 'rm -rf *-inspec.xml'
		}
	}
}

timestamps {
	ansiColor('xterm') {
		node('chefdk && (osx || linux)') {
			stage('Checkout') {
				checkout scm
				isMaster = env.BRANCH_NAME.equals('master')
			} // stage

			stage('Lint') {
				def foodcriticVersion = sh(returnStdout: true, script: 'foodcritic -V').trim()
				echo "foodcritic version: ${foodcriticVersion}"
				def cookstyleVersion = sh(returnStdout: true, script: 'cookstyle -V').trim()
				echo "cookstyle version: ${cookstyleVersion}"
				def berksVersion = sh(returnStdout: true, script: 'berks version').trim()
				echo "berks version: ${berksVersion}"
				def kitchenVersion = sh(returnStdout: true, script: 'kitchen -v').trim()
				echo "kitchen version: ${kitchenVersion}"

				sh(returnStatus: true, script: 'foodcritic -B .')
				sh(returnStatus: true, script: 'cookstyle --fail-level E .') // Cookstyle wraps rubocop

				warnings(
					consoleParsers: [[parserName: 'Foodcritic'], [parserName: 'Rubocop']],
					failedTotalAll: '0', // Fail if there are *any* warnings
					canComputeNew: false,
					canResolveRelativePaths: false,
					defaultEncoding: '',
					excludePattern: '',
					healthy: '',
					includePattern: '',
					messagesPattern: '',
					unHealthy: '')
				// This doesn't seem to "fail" the build immediately if there are warnings!
				if (currentBuild.resultIsWorseOrEqualTo('FAILURE')) {
					error 'Warnings detected'
					return
				}

				// Now collect the name of all the test instances we can run
				def listing = sh(returnStdout: true, script: 'kitchen list --bare').trim()
				tests = listing.split(/\r?\n/)

				// stash the source code for testing later
				stash excludes: 'nodes/', name: 'sources'
			} // stage
		} // node

		stage('Test') {
			// Now generate the mapping of test name to test execution to run them all in parallel
			def parallelTests = [:] // Don't fail fast because we always want to clean up after each VM!
			for (int i = 0; i < tests.size(); i++) {
				def testName = tests[i]
				parallelTests[testName] = unitTests(testName)
			}
			parallel(parallelTests)
		} // stage

		if (isMaster) {
			stage('Deploy') {
				node('chefdk && (osx || linux) && axway-internal') {
					unstash 'sources'
					sh 'berks install'
					sh 'berks upload android'
				} // node
			} // stage('Deploy')
		} // if (isMaster)
	} // ansiColor
} // timestamps
