package org.openjfx.dto;

import java.io.*;

public class GitBash implements Runnable {

    private static final String SEPARATOR = " ; ";

    private final ScriptType scriptType;
    private final String command;

    public GitBash(ScriptType scriptType, String command) {
        this.scriptType = scriptType;
        this.command = command;
    }

    public void run() {
        runCommand(scriptType, command);
    }

    private static void runCommand(ScriptType scriptType, String command) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder();
            String finalCommand = getOpenDirectoryCommand(scriptType) + SEPARATOR + command;
            if (!ScriptType.OPEN_REMOTE_APP_SCRIPT.equals(scriptType)) {
                finalCommand += (SEPARATOR + getWaitingForButtonCommand());
            }
            processBuilder.command(Setting.BASH_PATH.getValue(), "-c", finalCommand);
            processBuilder.start();
        } catch (IOException e) {
            System.out.println(" --- Interruption in RunCommand: " + e);
            Thread.currentThread().interrupt();
        }
    }

    private static String getOpenDirectoryCommand(ScriptType scriptType) {
        return "cd " + scriptType.getPath();
    }

    private static String getWaitingForButtonCommand() {
        return "echo '\n\nPress any button to exit...'" + SEPARATOR + "read";
    }

}