#! groovy

timestamps {
	node('chefdk && (osx || linux)') {
		def isMaster = false

		stage('Checkout') {
			checkout scm

			isMaster = env.BRANCH_NAME.equals('master')
		}

		ansiColor('xterm') {
			stage('Lint') {
				def foodcriticVersion = sh(returnStdout: true, script: 'foodcritic -V').trim()
				echo "foodcritic version: ${foodcriticVersion}"
				def cookstyleVersion = sh(returnStdout: true, script: 'cookstyle -V').trim()
				echo "cookstyle version: ${cookstyleVersion}"
				def berksVersion = sh(returnStdout: true, script: 'berks version').trim()
				echo "berks version: ${berksVersion}"
				def kitchenVersion = sh(returnStdout: true, script: 'kitchen -v').trim()
				echo "kitchen version: ${kitchenVersion}"

				ansiColor('xterm') {
					sh(returnStatus: true, script: 'foodcritic -f correctness -B .')
					sh(returnStatus: true, script: 'cookstyle --fail-level E .') // Cookstyle wraps rubocop
				} // ansiColor
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
			} // stage

			stage('Test') {
				sh 'berks install' // installs all the cookbooks to local cache, using Berksfile.lock
				try {
					sh 'kitchen test default-ubuntu-1604'
				}
				finally {
					junit '*_inspec.xml'
				}
			} // stage

			stage('Deploy') {
				if (isMaster) {
					sh 'berks upload android-sdk' // Try to upload new cookbook to chef server
				}
			} // stage
		} // ansiColor
	} // node
} // timestamps
