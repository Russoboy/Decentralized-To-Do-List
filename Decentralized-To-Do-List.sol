// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoList {
    struct Task {
        uint id;
        string content;
        bool completed;
    }

    mapping(address => Task[]) private userTasks;
    event TaskCreated(address indexed user, uint id, string content);
    event TaskCompleted(address indexed user, uint id, bool completed);

    function createTask(string memory _content) external {
        uint taskId = userTasks[msg.sender].length;
        userTasks[msg.sender].push(Task(taskId, _content, false));
        emit TaskCreated(msg.sender, taskId, _content);
    }

    function getTasks() external view returns (Task[] memory) {
        return userTasks[msg.sender];
    }

    function toggleTask(uint _id) external {
        require(_id < userTasks[msg.sender].length, "Invalid task ID");
        userTasks[msg.sender][_id].completed = !userTasks[msg.sender][_id].completed;
        emit TaskCompleted(msg.sender, _id, userTasks[msg.sender][_id].completed);
    }
}
