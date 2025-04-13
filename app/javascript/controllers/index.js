import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import { application } from "./application"

eagerLoadControllersFrom("controllers", application)
